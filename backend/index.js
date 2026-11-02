require('dotenv').config();
const express = require('express');
const cors = require('cors');
const errorHandler = require('./middlewares/errorHandler');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ nom: 'VavakaFamindrapo API', statut: 'ok' });
});

app.use('/api/livres', require('./routes/livres'));
app.use('/api/prieres', require('./routes/prieres'));
app.use('/api/search', require('./routes/recherche'));
app.use('/api/favoris', require('./routes/favoris'));
app.use('/api/admin', require('./routes/admin'));

app.use((req, res) => res.status(404).json({ erreur: 'Route introuvable' }));
app.use(errorHandler);

app.listen(PORT, () => console.log(`Serveur démarré sur http://localhost:${PORT}`));