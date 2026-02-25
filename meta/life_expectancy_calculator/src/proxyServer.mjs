import express from 'express';
import cors from 'cors';
import fetch from 'node-fetch';

const app = express();
const port = 3001;

app.use(cors());

app.get('/dataCounties', async (req, res) => {
    try {
        const { id } = req.query;
        console.log(`Fetching data for ID: ${id}`); // Logging the ID

        const response = await fetch('http://localhost:8000/dataCounties.json');
        if (!response.ok) {
            throw new Error('Network response was not ok ' + response.statusText);
        }

        const data = await response.json();
        const county = data.counties.find(county => county.id === parseInt(id, 10));

        if (!county) {
            return res.status(404).json({ error: 'County not found' });
        }

        res.json(county);
    } catch (error) {
        console.error('Error fetching data:', error);
        res.status(500).json({ error: 'An error occurred while fetching data' });
    }
});

app.get('/dataCensusTracks', async (req, res) => {
    try {
        const { id, year } = req.query;
        console.log(`Fetching data for county ID and year: ${id}, ${year}`);

        const response = await fetch('http://localhost:8000/census_yearly_data.json');

        if (!response.ok) {
            throw new Error('Network response was not ok ' + response.statusText);
        }

        const data = await response.json();
        const censusTrack = data.census.find(census => census.id === parseInt(id, 10) && census.year === parseInt(year));
        if (!censusTrack) {
            return res.status(404).json({ error: 'censusTrack not found' });
        }
        res.json(censusTrack)

    }
    catch (error) {
        console.error('Error fetching data:', error);
        res.status(500).json({ error: 'An error occurred while fetching data' });
    }
});

app.get('/dataCountiesWithCensusTracks', async (req, res) => {
    try {
        const { countyId, year } = req.query;

        const response = await fetch('http://localhost:8000/census_yearly_data.json');
        
        if (!response.ok) {
            throw new Error('Network response was not ok ' + response.statusText);
        }

        const Jsondata = await response.json()
        const data = Jsondata.census
        console.log(`Fetching data for county ID and year: ${countyId}, ${year}`);
        // Filter census tracts based on the county ID
        const filteredCensusTracks = data.filter(
            censusTrack => censusTrack.id.toString().startsWith(countyId) && censusTrack.year === parseInt(year));
        res.json(filteredCensusTracks);


    }
    catch (error) {
        console.error('Error fetching data:', error);
        res.status(500).json({ error: 'An error occurred while fetching data' });
    }
})


app.listen(port, () => {
    console.log(`Proxy server listening at http://localhost:${port}`);
});
