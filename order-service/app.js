const express = require('express');
const bodyParser = require('body-parser');

const port = process.env.PORT || 3001;

const app = express();
app.use(bodyParser.json());

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
app.post('/order-created', (req, res) => {
    console.log('Order created event received:', req.body);
    // Process the order event
    res.status(200).send('OK');
});

app.listen(port, () => console.log(`Order-service App listening on port ${port} and subscribed to events!`));