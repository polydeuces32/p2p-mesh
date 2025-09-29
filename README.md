# P2P Mesh - Vercel Deployment

A decentralized messaging application with Bauhaus design, deployed on Vercel.

## 🚀 Live Demo

**Deployed on Vercel**: [https://p2p-mesh.vercel.app](https://p2p-mesh.vercel.app)

## 🎨 Features

- **Bauhaus Design**: Clean, functional interface
- **P2P Messaging**: Real-time peer-to-peer communication
- **Phone Number IDs**: User identification system
- **Global Network**: Worldwide messaging via Vercel
- **WebSocket Support**: Real-time bidirectional communication
- **Mobile Responsive**: Works on all devices

## 🛠️ Tech Stack

- **Frontend**: HTML5, CSS3, JavaScript
- **Backend**: FastAPI, Python
- **Deployment**: Vercel
- **WebSocket**: Real-time communication
- **Design**: Bauhaus principles

## 📱 Usage

1. **Set Phone Number**: Enter your phone number (e.g., +1234567890)
2. **Connect Global**: Click "Connect Global" to join the network
3. **Send Messages**: Type and send messages to connected users
4. **Real-time**: Messages appear instantly across all connected devices

## 🔧 Local Development

```bash
# Clone the repository
git clone https://github.com/polydeuces32/p2p-mesh.git
cd p2p-mesh

# Install dependencies
pip install -r requirements.txt

# Run locally
python api/main.py
```

## 🌐 Vercel Deployment

### Automatic Deployment
1. Fork this repository
2. Connect to Vercel
3. Deploy automatically

### Manual Deployment
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel --prod
```

## 📊 API Endpoints

- `GET /` - Main application
- `GET /health` - Health check
- `GET /users` - Active users
- `WebSocket /ws` - Real-time messaging

## 🎯 Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Vercel API    │    │   WebSocket     │
│   (HTML/CSS/JS) │◄──►│   (FastAPI)     │◄──►│   (Real-time)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔒 Security

- **CORS Enabled**: Cross-origin requests allowed
- **WebSocket Security**: Secure real-time communication
- **Input Validation**: Phone number validation
- **No Data Storage**: Messages not permanently stored

## 📈 Performance

- **Vercel Edge**: Global CDN distribution
- **WebSocket**: Low-latency communication
- **Responsive**: Mobile-first design
- **Fast Loading**: Optimized assets

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

## 👨‍💻 Author

**GiancarloV** - [@polydeuces32](https://github.com/polydeuces32)

---

**P2P Mesh** - Decentralized communication for the modern world 🌍📱
