require('dotenv').config();
const express = require('express');
const cors = require('cors');
const errorHandler = require('./middlewares/errorHandler');
const compression = require('compression');
const supabase = require('./config/supabase');
const asyncHandler = require('./middlewares/asyncHandler');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(compression());
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

app.use('/api/sync', require('./routes/sync'));

app.get('/api/sante', asyncHandler(async (req, res) => {
  const { error } = await supabase.from('livres').select('id').limit(1);
  if (error) throw error;
  res.json({ statut: 'ok' });
}));

app.listen(PORT, () => console.log(`Serveur démarré sur http://localhost:${PORT}`));