const express = require('express');
const bodyParser = require('body-parser');

const port = process.env.PORT || 3000;

const app = express();
app.use(bodyParser.json({ type: 'application/*+json' }));

// Dapr subscription endpoint
app.get('/dapr/subscribe', (req, res) => {
    res.json([
        {
            pubsubname: "pubsub",
            topic: "order-created",
            route: "/order-created"
        }
    ]);
});

// Handle order created events
app.post('/order-created', async (req, res) => {
    const { productId, quantity, customerId } = req.body.data;
    console.log(`Order created event received: productId=${productId}, quantity=${quantity}, customerId=${customerId}`);
    // Process the order event
    res.status(200).send('OK');
});

app.listen(port, () => console.log(`Order-service App listening on port ${port} and subscribed to events!`));