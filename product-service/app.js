const express = require('express');
const bodyParser = require('body-parser');
require('isomorphic-fetch');

const port = process.env.PORT || 3000;
const daprPort = process.env.DAPR_HTTP_PORT || 3500;
const daprEnv = process.env.DAPR_HTTP_ENV || 'pubsub';
const daprUrl = `http://localhost:${daprPort}`;

const app = express();
app.use(bodyParser.json());

app.get('/', (req, res) => {
    res.send('Order Service is running!');
});

// Publish order events
app.post('/order-products', async (req, res) => {
    const order = req.body;

    try {
        await fetch(`${daprUrl}/v1.0/publish/${daprEnv}/order-created`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(order)
        });

        res.status(201).json({ message: 'Order created and event published' });
    } catch (error) {
        res.status(500).json({ error: 'Failed to publish event' });
    }
});

app.listen(port, () => console.log(`Product service listening on port ${port}!`));