import 'leaflet/dist/leaflet.css';
import { MapContainer, TileLayer, Marker, Popup, GeoJSON, LayersControl } from 'react-leaflet';
import L from 'leaflet';
import markerIcon from 'leaflet/dist/images/marker-icon.png';
import markerShadow from 'leaflet/dist/images/marker-shadow.png';
import 'leaflet/dist/leaflet.css';
import VirginiaGeoJson from './components/VACountiesJson';
import VirginiaCensusTracks from './components/VACensusTracks';
import dataCensusTracks from './data/dataCensusTracks.json'
import { useEffect, useState, useRef } from 'react';


// Fix default icon paths
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
    iconRetinaUrl: markerIcon,
    iconUrl: markerIcon,
    shadowUrl: markerShadow,
});

const average =  (countyData,id) => {
    if (countyData.length === 0) return {};
    console.log("county",countyData);
    const features = [
        "gini",
        "averageYearsSchooling",
        "employmentAccessIndex",
        "walkabilityIndex",
        "segregationIndicator",
        "affordabilityIndex",
        "environmentalHazardIndex",
        "foodAccessPercentage",
        "incarcerationRate",
        "laborParticipateRate",
        "towsend_material_deprivation",
        "mobility"
    ];

    const totals = features.reduce((acc, feature) => {
        acc[feature] = 0;
        return acc;
    }, {});

    countyData.forEach((tract) => {
        features.forEach((feature) => {
            totals[feature] += tract[feature];
        });
    });

    const averages = features.reduce((acc, feature) => {
        acc[feature] = totals[feature] / countyData.length;
        return acc;
    }, {});
    averages["id"]=id
     return averages;
};

const fetchData = async (id, onDataFetch, vadivisions, year) => {
    console.log("id: " + id)
    console.log("vadivisions: " + vadivisions)

    var response;
    try {
        if (vadivisions === "counties") {
            response = await fetch(`http://localhost:3001/dataCountiesWithCensusTracks?countyId=${id}&year=${year}`)
            const data = await response.json()
            const avg=average(data,id)
            console.log("datain", data)
            console.log("datain", avg)
            onDataFetch(avg)
        }
        else {
            response = await fetch(`http://localhost:3001/dataCensusTracks?id=${id}&year=${year}`)
            const data = await response.json()
            onDataFetch(data)
        }

        if (!response.ok) {
            throw new Error('Network response was not ok ' + response.statusText);
        }
        // const data = await response.json()
        // onDataFetch(data)
        // console.log('Fetched data:', data);

    } catch (error) {
        console.error('There was a problem with the fetch operation:', error);
    }

}
let clickedLayer = null;

const Leaflet = ({ onDataFetch }) => {
    const [vadivisions, updateVadivisions] = useState('counties')
    const [mapData, updateMapData] = useState(null)
    const [countiesData, setCountiesData] = useState(null);
    const [censusTracksData, setCensusTracksData] = useState(null);

    const [selectedYear, setSelectedYear] = useState(2018);
    const selectedYearRef = useRef(selectedYear);
    
    useEffect(() => {
        console.log("UseEffect is running!")

        setCountiesData(VirginiaGeoJson)
        setCensusTracksData(VirginiaCensusTracks)
        updateMapData(VirginiaGeoJson)
    }, []);

    useEffect(() => {
        selectedYearRef.current = selectedYear;
    }, [selectedYear]);

    const onEachFeature = (feature, layer, onDataFetch, vadivisions) => {
        layer.on({
            click: (e) => {
                console.log("vadivisions", vadivisions);
    
                const currentLayer = e.target;
    
                // Check if there's a previously clicked layer
                if (clickedLayer && clickedLayer !== currentLayer) {
                    // Revert the style of the previously clicked layer
                    clickedLayer.setStyle({
                        stroke: '#000000',
                        color: 'green',
                        weight: 1.5,
                        fillOpacity: 0
                    });
                    // Remove the tooltip from the previously clicked layer
                    clickedLayer.unbindTooltip();
                }
    
                // Set the clicked layer as the current layer
                clickedLayer = currentLayer;
    
                // Apply the new style to the clicked layer
                currentLayer.setStyle({
                    stroke: '#000000',
                    color: "#72A26E",
                    fill: '#72A26E', // Change fill color on click
                    strokeWidth: 1,
                    fillOpacity: 1
                });
    
                // Bind and open tooltip
                if (vadivisions == "counties") {
                    const censusTracks = dataCensusTracks.census.filter(item => String(item.id).substring(0, 5) == String(feature.properties.id));
                    const tracks = censusTracks.map(track => (track.name).substring((track.name).indexOf('t') + 2, (track.name).indexOf(',')))
                    const trackList = []
    
                    for (let i = 0; i < tracks.length; i += 6) {
                        trackList.push(tracks.slice(i, i + 6).join(', '));
                    }
    
                    console.log(tracks)
                    currentLayer.bindTooltip(`${feature.properties.name} <br> ${trackList.join('<br> ')}`, {
                        permanent: true,
                        direction: "auto"
                    }).openTooltip();
                }
    
                if (vadivisions == "censusTracks") {
                    const censusTrack = dataCensusTracks.census.find(item => item.id == feature.properties.id);
    
                    currentLayer.bindTooltip(`${(censusTrack.name).substring(0, (censusTrack.name).lastIndexOf(', Virginia'))}`, {
                        permanent: true,
                        direction: "auto"
                    }).openTooltip();
                }
    
                console.log("id", feature.properties)
                if (feature.properties && feature.properties.id) {
                    console.log("id", feature.properties.id);
                    fetchData(feature.properties.id, onDataFetch, vadivisions, selectedYearRef.current);
                }
    
                // Prevent event propagation to avoid triggering mouseout event
                e.originalEvent.stopPropagation();
            },
            mouseout: (e) => {
                // Don't change style if this layer is the currently clicked layer
                if (e.target === clickedLayer) return;
    
                const layer = e.target;
                layer.setStyle({
                    stroke: "#000000",
                    color: 'green',
                    weight: 1.5,
                    fillOpacity: 0
                });
            },
            mouseover: (e) => {
                const layer = e.target;
                // Only change the style if the layer is not the currently clicked layer
                if (layer !== clickedLayer) {
                    layer.setStyle({
                        stroke: "#000000",
                        color: 'blue', // Change color on mouseover
                        weight: 2,
                        fillOpacity: 0.5
                    });
                }
            }
        });
    };

    const handleNextYear = () => {
        if (selectedYear < 2021) {
            setSelectedYear(prevYear => prevYear + 1);
        }
    };

    const handlePreviousYear = () => {
        if (selectedYear > 2015) {
            setSelectedYear(prevYear => prevYear - 1);
        }
    };

    const handleFilter = (event) => {
        const selectedValue = event.target.value
        //updateVadivisions(selectedValue)
        //updateMapData(selectedValue === "counties" ? countiesData : censusTracksData)
        console.log(mapData)
    }

    return (
        <div>
            <div style={{ paddingBottom: '75px' }} />

            <div style={{ marginBottom: '8px', fontSize: '12px'  }}>Selected Year</div>

            <div id="yearButtons" style={{ marginBottom: '40px' }}>
                <span style={{ margin: '0 10px', fontSize: '14px' }}>2015</span>
                <button style={{ backgroundColor: 'white', border: '1px solid #ccc', padding: '8px 6px' }} onClick={handlePreviousYear}> &lt; </button>
                <span style={{ margin: '0 12px', fontSize: '25px' }}><b>{selectedYear}</b></span>
                <button style={{ backgroundColor: 'white', border: '1px solid #ccc', padding: '8px 6px' }} onClick={handleNextYear}> &gt; </button>
                <span style={{ margin: '0 10px', fontSize: '14px' }}>2021</span>
            </div>

            <MapContainer center={{ lat: 37.9, lng: -78.8 }} zoom={6.5} scrollWheelZoom={false} style={{ height: "70vh", width: "100vh" }}>
            <LayersControl position="topright" collapsed={false}>
                <TileLayer
                    attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                    url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                />

                <LayersControl.BaseLayer checked name="Counties">
                    <GeoJSON
                        key={JSON.stringify(countiesData)}
                        data={countiesData}
                        style={{ stroke: "#000000", color: 'green', weight: 0.5, fillOpacity: 0 }}
                        onEachFeature={(feature, layer) => onEachFeature(feature, layer, onDataFetch, 'counties')}
                    />
                </LayersControl.BaseLayer>
                <LayersControl.BaseLayer name="Census Tracks">
                    <GeoJSON
                        key={JSON.stringify(censusTracksData)}
                        data={censusTracksData}
                        style={{ stroke: "#000000", color: 'green', weight: 0.5, fillOpacity: 0 }}
                        onEachFeature={(feature, layer) => onEachFeature(feature, layer, onDataFetch, 'censusTracks')}
                    />
                </LayersControl.BaseLayer>
            </LayersControl>
            </MapContainer>

            <div style={{ paddingTop: '30px' }} />
        </div>

    );
}

export default Leaflet;
