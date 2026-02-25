from bs4 import BeautifulSoup as bs
import bs4
import regex as re
import requests
import pandas as pd
from tqdm import tqdm
import time
import random

def analyze_search_result(asset_card: bs4.element.Tag):
    # get the type of listing of the asset card, example:
    # ['placard', 'placard-option-diamond', 'has-header', 'js-diamond']
    # 6 levels: premium, diamond, gold, silver, prosumer, basic
    listing_class = asset_card.findChild('article')['class']
    
    if listing_class[2] == 'has-header':  # for listings with a proper header/logo
        property_info_card = asset_card.findChild('div', class_="property-information")
        
        # tag a is the section of detailed info for hyperlink associated
        property_tag_a = property_info_card.findChild('a', class_="property-link")
        url = property_tag_a['href']
        title = property_tag_a.findChild('div', class_="property-title").getText().strip()
        
        address_prompt = property_info_card.findChild('div', class_="property-address js-url")
        address = address_prompt.getText().strip()
        
    
        address = address_prompt['title'].strip()
        
    elif listing_class[3] == 'js-prosumer' or listing_class[3] == 'js-basic':  # anonymous listings
        property_info_card = asset_card.findChild('div', class_="property-info")
        
        property_tag_a = property_info_card.findChild('a', class_="property-link")
        url = property_tag_a['href']
        title = property_tag_a.findChild('div', class_="property-title").getText().strip()
        
        address_prompt = property_info_card.findChild('div', class_="property-address js-url")
        address = address_prompt.getText().strip()
        
    else:  # listings without a logo, but still a brand/name
        property_info_card = asset_card.findChild('div', class_="property-info")
        
        property_tag_a = property_info_card.findChild('a', class_="property-link")
        url = property_tag_a['href']
        title = property_tag_a['aria-label'].strip()
        # remove the city,state suffix by locating the second last comma
        title = title[:title.rfind(',', 0, title.rfind(','))]
        
        address_prompt = property_info_card.findChild('p', class_="property-address js-url")
        address = address_prompt.getText().strip()
        
    return (title, url, address, listing_class)

def analyze_rental_detail(url, session: requests.Session, req_headers: dict, available_only: bool, 
                          single_unit: bool, sleep_time_range=(0.1, 0.5)):
    
    def get_float_or_none(reg_exp, text, group=1):
        # helper function to handle assets that miss partially the information
        result = re.search(reg_exp, text).group(group).strip()
        try:
            result = float(re.sub(r'\$|,', '', result))
            return result
        except (ValueError, AttributeError):
            return None
    
    # get each property's detailed info page via the url
    plan_output = []
    unit_output = []
    soup = bs(session.get(url=url, headers = req_headers).content, 'html.parser')
    time.sleep(random.uniform(sleep_time_range[0], sleep_time_range[1]))
    
    if single_unit:
        info_element = soup.find('ul', class_='priceBedRangeInfo')
        info = info_element.getText()
        info = re.sub('\s+', ' ', info.replace('\n', ' ')).strip().lower()
        
        price = get_float_or_none(r"monthly rent (.+) bedroom", info)
        bedrooms = get_float_or_none(r"bedroom[s]? (.+) bd", info)
        bathrooms = get_float_or_none(r"bathroom[s]? (.+) bd", info)
        square_feet = get_float_or_none(r"square feet (.+) sq ft", info)
        
        plan_info = {'url': url, 'plan_name': '', 'available': True,
                     'price_range': str(price), 'bedrooms': bedrooms,
                     'bathrooms': bathrooms, 'area_sq_ft': square_feet,
                     'detail_text': 'single-unit property'}
        plan_output.append(plan_info)
        unit_info = {'url': url, 'plan_name': '','bedrooms': bedrooms, 'bathrooms': bathrooms,
                  'unit': '', 'price': price, 'size_sqft': square_feet}
        unit_output.append(unit_info)
        return plan_output, unit_output
        
    else:  # properties with multiple units for rental
        available_plans = soup.find_all('div', class_='pricingGridItem multiFamily hasUnitGrid')
        plans = available_plans
        availability_labels = [True] * len(available_plans)       
        if not available_only:
            unavailable_plans = soup.find_all('div', class_="jsAvailableModels hideModelCardOnCollapsed")
            plans += unavailable_plans
            availability_labels += [False] * len(unavailable_plans)
        
        for plan, availability in zip(plans, availability_labels):
            model_name_element = plan.findChild('span', class_="modelName")
            rent_label = model_name_element.find_next_sibling('span').getText().strip()
            model_name = model_name_element.getText().strip()
            plan_detail = model_name_element.parent.find_next_sibling().getText()
            plan_detail = re.sub('\s+',' ',plan_detail.replace('\n', ' ')).strip().lower()
            
            # use 0 bedrooms to represent studio, a conventioned approach in their html
            # note that there is a difference in None and 0 in the output df
            plan_bed = get_float_or_none(r"([0-9]+) bed",
                                         plan_detail.replace('studio', '0 beds'))
            plan_bath = get_float_or_none(r'([0-9]+) bath', plan_detail)
            plan_area = get_float_or_none(r'([0-9]+) bath', 
                                          plan_detail.replace(',', ''))
            
            plan_info = {'url': url, 'plan_name': model_name, 'available': availability,
                         'price_range': rent_label, 'bedrooms': plan_bed,
                         'bathrooms': plan_bath, 'area_sq_ft': plan_area,
                         'detail_text': plan_detail}
            plan_output.append(plan_info)
            
            if not availability:  # unavailable plans does not provide per-unit information
                continue
            
            units = plan.findChildren('li', class_="unitContainer js-unitContainer")
            # loop through each unit offered in each plan
            for unit in units:
                # the bed and bath count is embeded directly in the <li ...>
                bed_count = unit['data-beds']
                bath_count = unit['data-baths']
                
                # other info is embeded in text
                info_text = re.sub("[\r]?\n[\n\r]?","",unit.getText().replace(" ",''))
                unit_id = re.search(r"Unit(.+)price",info_text).group(1).strip()
                price = get_float_or_none(r"price(.+)squarefeet", info_text)
                square_feet = get_float_or_none(r"squarefeet(.+)availibility", info_text)
                    
                unit_info = {'url': url, 'plan_name': model_name,'bedrooms': bed_count, 
                             'bathrooms': bath_count, 'unit': unit_id, 'price': price, 
                             'size_sqft': square_feet}
                unit_output.append(unit_info)
        return plan_output, unit_output

def get_search_results(city, state, session: requests.Session, req_headers: dict):
    # get and extract basic information for all results of the searched city
    city = city.replace(' ', '-').lower()
    state = state.lower()
    base_url = 'https://www.apartments.com/{0}-{1}/'.format(city, state)
    
    response = session.get(url=base_url,headers = req_headers)
    print('Response Code:', response.status_code)

    search_soup = bs(response.content, 'html.parser')
    asset_cards = search_soup.find_all('li', class_="mortar-wrapper")

    page_prompt = search_soup.find('span', class_='pageRange')
    try:
        page_range = re.findall(r'[0-9]+', page_prompt.getText())[1]
        page_range = int(page_range)
    except (ValueError, AttributeError):
        page_range = 1
    
    
    for i in range(2, page_range+1):
        url = base_url + str(i) + '/'
        response = session.get(url=url, headers = req_headers)
        search_soup = bs(response.content, 'html.parser')
        cards_from_one_page = search_soup.find_all('li', class_="mortar-wrapper")
        asset_cards += cards_from_one_page
    
    properties = []
    for asset_card in asset_cards:
        card_info = analyze_search_result(asset_card)
        property_info = {'property_title': card_info[0], 'url': card_info[1], 
                         'address': card_info[2], 'listing_class': card_info[3]}
        properties.append(property_info)
    properties = pd.DataFrame(properties)
    
    return properties

#%%
city, state = 'Fairfax County', 'VA'

req_headers = {
    'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
    'accept-encoding': 'gzip, deflate, br',
    'accept-language': 'en-US,en;q=0.8',
    'upgrade-insecure-requests': '1',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36',
    'referer': 'https://www.apartments.com/'
}
session = requests.session()

properties = get_search_results(city, state, session, req_headers)

#%%
available_only = False

plan_results = []
unit_results = []

with tqdm(total = properties.shape[0], leave=True, position=0,
          bar_format='{desc:<5.5}{percentage:3.0f}%|{bar:60}{r_bar}') as pbar:
    for _, prop in properties.iterrows():
        url = prop['url']
        single_unit = prop['listing_class'][3] in ['js-prosumer', 'js-basic']
        plans, units = analyze_rental_detail(url, session, req_headers, available_only, single_unit)
        plan_results += plans
        unit_results += units
        pbar.update(1)
plan_output = pd.merge(properties, pd.DataFrame(plan_results), on='url', how='right')
unit_output = pd.merge(properties, pd.DataFrame(unit_results), on='url', how='right')

#%%
plan_output.to_csv('../../data/housing_apartment_listing/original/apartments-floor-plans_{0}-{1}.csv'.format(city, state))
unit_output.to_csv('../../data/housing_apartment_listing/original/apartments-available-units_{}-{}.csv'.format(city, state))
