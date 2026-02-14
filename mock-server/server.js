// mock-server/server.js
const jsonServer = require('json-server');
const server = jsonServer.create();
const router = jsonServer.router('db.json');
const middlewares = jsonServer.defaults();
const port = 3000;

// Middleware pour parser le JSON
server.use(jsonServer.bodyParser);
server.use(middlewares);

// Custom routes pour l'authentification
server.post('/auth/signup', (req, res) => {
  const db = router.db; // Accès à la base de données
  const users = db.get('users');
  
  // Vérifier si l'email existe déjà
  const existingUser = users.find({ email: req.body.email }).value();
  
  if (existingUser) {
    return res.status(400).json({
      error: 'Email already exists'
    });
  }
  
  // Créer le nouvel utilisateur
  const newUser = {
    id: Date.now().toString(),
    ...req.body,
    isEmailVerified: false,
    createdAt: new Date().toISOString()
  };
  
  users.push(newUser).write();
  
  // Générer un token
  const token = `token_${newUser.id}_${Date.now()}`;
  
  res.status(201).json({
    userId: newUser.id,
    token: token,
    requiresEmailVerification: true
  });
});

server.post('/auth/login', (req, res) => {
  const db = router.db;
  const { email, password } = req.body;
  
  const user = db.get('users')
    .find({ email: email, password: password })
    .value();
  
  if (!user) {
    return res.status(401).json({
      error: 'Invalid email or password'
    });
  }
  
  const token = `token_${user.id}_${Date.now()}`;
  
  res.json({
    token: token,
    user: user
  });
});

server.post('/auth/send-otp', (req, res) => {
  const db = router.db;
  const { userIdOrEmail } = req.body;
  
  let user;
  if (userIdOrEmail.includes('@')) {
    user = db.get('users').find({ email: userIdOrEmail }).value();
  } else {
    user = db.get('users').find({ id: userIdOrEmail }).value();
  }
  
  if (!user) {
    return res.status(404).json({
      error: 'User not found'
    });
  }
  
  // Créer un OTP (toujours 123456 pour le test)
  const otp = {
    id: Date.now().toString(),
    userId: user.id,
    code: '123456',
    expiresAt: new Date(Date.now() + 5 * 60000).toISOString(), // 5 minutes
    used: false
  };
  
  db.get('otps').push(otp).write();
  
  console.log(`📧 OTP sent to ${user.email}: 123456`); // Pour le débogage
  
  res.json({
    success: true,
    expiresIn: 300,
    message: 'OTP sent successfully'
  });
});

server.post('/auth/verify-otp', (req, res) => {
  const db = router.db;
  const { userIdOrEmail, code } = req.body;
  
  let user;
  if (userIdOrEmail.includes('@')) {
    user = db.get('users').find({ email: userIdOrEmail }).value();
  } else {
    user = db.get('users').find({ id: userIdOrEmail }).value();
  }
  
  if (!user) {
    return res.status(404).json({
      error: 'User not found'
    });
  }
  
  // Vérifier l'OTP
  const otp = db.get('otps')
    .find({ userId: user.id, code: code, used: false })
    .value();
  
  if (!otp) {
    return res.status(400).json({
      error: 'Invalid verification code'
    });
  }
  
  // Vérifier l'expiration
  if (new Date(otp.expiresAt) < new Date()) {
    return res.status(400).json({
      error: 'Code expired'
    });
  }
  
  // Marquer l'OTP comme utilisé
  db.get('otps')
    .find({ id: otp.id })
    .assign({ used: true })
    .write();
  
  // Marquer l'email comme vérifié
  db.get('users')
    .find({ id: user.id })
    .assign({ isEmailVerified: true })
    .write();
  
  res.json({
    verified: true,
    message: 'Email verified successfully'
  });
});

// Route pour mettre à jour le profil
server.put('/profile/:id', (req, res) => {
  const db = router.db;
  const userId = req.params.id;
  const { phone, country, currency, language } = req.body;
  
  const user = db.get('users').find({ id: userId }).value();
  
  if (!user) {
    return res.status(404).json({
      error: 'User not found'
    });
  }
  
  // Mettre à jour seulement les champs fournis
  const updatedUser = {
    ...user,
    ...(phone && { phone }),
    ...(country && { country }),
    ...(currency && { currency }),
    ...(language && { language })
  };
  
  db.get('users')
    .find({ id: userId })
    .assign(updatedUser)
    .write();
  
  res.json({
    user: updatedUser
  });
});

// Route pour récupérer un utilisateur par email
server.get('/users/email/:email', (req, res) => {
  const db = router.db;
  const email = req.params.email;
  
  const user = db.get('users').find({ email: email }).value();
  
  if (!user) {
    return res.status(404).json({
      error: 'User not found'
    });
  }
  
  res.json(user);
});

// Utiliser le router JSON Server pour les routes standard
server.use('/api', router);

server.listen(port, () => {
  console.log(`🚀 Mock API Server running on http://localhost:${port}`);
  console.log(`📚 Resources:`);
  console.log(`   • Users: http://localhost:${port}/users`);
  console.log(`   • Auth: http://localhost:${port}/auth/login`);
  console.log(`   • Profile: http://localhost:${port}/profile/:id`);
});