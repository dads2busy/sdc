import './App.css';
import Slider from './Slider';
import { Tooltip } from "react-tooltip";
import 'react-tooltip/dist/react-tooltip.css';
import { useState, useEffect } from 'react';
import Leaflet from './Leaflet';

function App() {
  const [sliderValues, setSliderValues] = useState({
    id2: 13.27,
    id3: 9879.46,
    id4: 58.83,
    id5: 20,
    id6: 3.20,
    id7: 14.24,
    id8: 0.45,
    id9: 48.22,
    id10: -0.48,
    id11: 21.15,
    id12: 0.34,
    id13: 20,
    id14: 677.71,
  });

  const [fetchedData, updateFetchedData] = useState(null);

  const handleSliderChange = (id, value) => {
    setSliderValues(prevValues => ({
      ...prevValues,
      [id]: value,
    }));
    calculateSum();
  };

  // const calculateSum = () => {
  //   const sum = ((((sliderValues.id6 - 3.17) / (16 - 3.17)) * 0.097) +
  //     (((sliderValues.id10 - (-2.15)) / (2.58 - (-2.15))) * 0.096) +
  //     (((sliderValues.id11 - 1.32) / (48.38 - 1.32)) * 0.041) +
  //     (((sliderValues.id3 - 1530) / (130244 - 1530)) * 0.015) +
  //     (((sliderValues.id4 - 37) / (78.90 - 37)) * 0.06) +
  //     (((sliderValues.id8 - 0.18) / (0.82 - 0.18)) * 0.002) +
  //     (((sliderValues.id14 - 27) / (1787 - 27)) * 0.347) +
  //     (((sliderValues.id2 - 11.90) / (16.26 - 11.90)) * 0.160) +
  //     (((sliderValues.id7 - 0.09) / (316.67 - 0.09)) * 0.050) +
  //     // (sliderValues.id1*0) +
  //     (((sliderValues.id13 - 4.04) / (31.79 - 4.04)) * 0.030) +
  //     (((sliderValues.id9 - 29) / (76 - 29)) * 0.001) +
  //     // (sliderValues.id5*0) +
  //     (((sliderValues.id12 - 0) / (1)) * 0.101)) * 100

  //   setCalculatedValue(sum.toFixed(1))
  // };
  //Censustracks


  /* So, the indicators that need to be inverted (1 - value) are:

Income Inequality
Affordability
Environmental
Food Access
Townsend (Material Deprivation)
Mobility
Incarceration
*/
  const calculateSum = () => {
    const sum = ((((sliderValues.id6 - 1.60) / (18.83 - 1.60)) * 0.097) +
      ((((sliderValues.id10 - (-3.24)) / (4.38 - (-3.24)))) * 0.096) +
      ((((sliderValues.id11 - (-25.00)) / (94.52 - (-25.00)))) * 0.041) +
      (((sliderValues.id3 - 1418) / (1237164 - 1530)) * 0.015) +
      (((sliderValues.id4 - 0) / (100 - 0)) * 0.06) +
      ((1-((sliderValues.id8 - 0.18) / (0.82 - 0.18))) * 0.002) +
      ((1-((sliderValues.id14 - 0) / (22222.00 - 0))) * 0.347) +
      (((sliderValues.id2 - 8.44) / (19.00 - 8.44)) * 0.160) +
      (((sliderValues.id7 - 0) / (1.68 - 0)) * 0.050) +
      // (sliderValues.id1*0) +
      ((((sliderValues.id13 - 0) / (100 - 0))) * 0.030) +
      ((1-((sliderValues.id9 - 10) / (86 - 10))) * 0.001) +
      // (sliderValues.id5*0) +
      ((1-((sliderValues.id12 - 0) / (1)) * 0.101))) * 100

    setCalculatedValue(sum.toFixed(1))
  };


  const [calculatedValue, setCalculatedValue] = useState('');

  useEffect(() => {
    if (fetchedData) {
      calculateSum();
    }
  }, [fetchedData]);


  const handleFetchedData = (data) => {
    updateFetchedData(data);
    console.log("Data fetched from Leaflet:", data);
    if (data.id) {
      handleSliderChange("id2", data.averageYearsSchooling);  // Assuming 'id8' is the Gini Index slider ID
      handleSliderChange("id3", data.employmentAccessIndex);  // Assuming 'id8' is the Gini Index slider ID
      handleSliderChange("id4", data.laborParticipateRate);  // Assuming 'id8' is the Gini Index slider ID
      handleSliderChange("id6", data.walkabilityIndex);  // Assuming 'id8' is the Gini Index slider ID
      handleSliderChange("id7", data.segregationIndicator);  // Assuming 'id8' is the Gini Index slider ID
      handleSliderChange("id8", data.gini);  // Assuming 'id8' is the Gini Index slider ID
      handleSliderChange("id9", data.affordabilityIndex);  // Assuming 'id8' is the Gini Index slider ID
      handleSliderChange("id10", data.environmentalHazardIndex);  // Assuming 'id8' is the Gini Index slider ID
      handleSliderChange("id11", data.foodAccessPercentage);  // Assuming 'id8' is the Gini Index slider ID
      handleSliderChange("id14", data.incarcerationRate);  // Assuming 'id8' is the Gini Index slider ID
      handleSliderChange("id12", data.towsend_material_deprivation);  // Assuming 'id8' is the Gini Index slider ID
      handleSliderChange("id13", data.mobility);  // Assuming 'id8' is the Gini Index slider ID
      calculateSum();
    }
    console.log(data.gini);
  };

  return (
    <div className='App'>
      <div style={{ paddingTop: '10px' }} />
      <Tooltip id="my-tooltip" />
      <button className="button-27" role="button" onClick={calculateSum}>{`Life Expectancy Calculator`}</button>
      <div className='app-container'>
        <div className='slider-container'>
          <div className='grid-container'>
            <Slider feature={"Average Years of Schooling"} text={"Education Index (Average Years of Schooling)"} id="id2" min="11.90" max="16.26" value={sliderValues.id2} onChange={handleSliderChange} />
            <Slider feature={"Employment Access Index"} text={"Employment access is the job accessibility at a location"} id="id3" min="1530" max="130244" value={sliderValues.id3} onChange={handleSliderChange} />
            <Slider feature={"Labor Force Participation Rate"} text={"The percentage of individuals aged 16 years and over in the labor force."} id="id4" min="37" max="78.90" value={sliderValues.id4} onChange={handleSliderChange} />
            <Slider feature={"Walkability Index"} text={"A measure of how walkable a community is."} id="id6" min="0" max="5" value={sliderValues.id6} onChange={handleSliderChange} />
            <Slider feature={"Segregation Indicator"} text={"It measures how different the population composition of a subarea is from the population composition of the State as a whole"} id="id7" min="0.09" max="316.67" value={sliderValues.id7} onChange={handleSliderChange} />
            <Slider feature={"Gini Index (Income Inequality)"} text={"The Gini Index is a summary measure of income inequality."} id="id8" min="0.36" max="0.62" value={sliderValues.id8} onChange={handleSliderChange} />
            <Slider feature={"Affordability Index"} text={"Affordability index is developed to measure the proportion of income spent on housing and transportation"} id="id9" min="29" max="76" value={sliderValues.id9} onChange={handleSliderChange} />
            <Slider feature={"Environmental Hazard Index"} text={"It examines the risk of exposure to environmental pollution."} id="id10" min="-2.15" max="2.58" value={sliderValues.id10} onChange={handleSliderChange} />
            <Slider feature={"Food Access Percentage"} text={"Low access, low-income population at 1 mile from supermarket."} min="1.32" max="48.38" id="id11" value={sliderValues.id11} onChange={handleSliderChange} />
            <Slider feature={"Towsend"} text={"It examines the private material resources available to households in a community."} id="id12" min="0" max="1" value={sliderValues.id12} onChange={handleSliderChange} />
            <Slider feature={"Mobility (Percentage of People Moving)"} text={"Mobility (Percentage of People Moving)"} id="id13" min="0" max="100" value={sliderValues.id13} onChange={handleSliderChange} />
            <Slider feature={"Incarceration Rate per 100,000"} text={"Incarceration Rate per 100,000"} id="id14" min="27.0" max="1787.0" value={sliderValues.id14} onChange={handleSliderChange} />
          </div>

        </div>
        <div style={{ paddingTop: '10px' }} />
        <div className='map-container'>
          <Leaflet onDataFetch={handleFetchedData} />
          <button className="button-27" role="button" onClick={calculateSum} style={{ textAlign: 'center', display: 'block', marginLeft: 'auto', width: '40%', paddingRight: '50px' }}>{`Life Expectancy: ${calculatedValue}`}</button>
        </div>
      </div>
    </div>
  );
}

export default App;
