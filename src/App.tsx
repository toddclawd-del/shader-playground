import { HashRouter, Routes, Route } from 'react-router-dom'
import { Home } from './pages/Home'
import { ShaderViewer } from './pages/ShaderViewer'

function App() {
  return (
    <HashRouter>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/:shaderId" element={<ShaderViewer />} />
      </Routes>
    </HashRouter>
  )
}

export default App
