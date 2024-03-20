
import Button from "./components/Button";
import Alert from "./components/Alert";
import { useState } from "react";

function App() {
  const [alertVisible, setAlertVisibility] = useState(false);  
  
  return (
  <div>
    { alertVisible && <Alert onClose={() => setAlertVisibility(false)}>My alert</Alert>}
    <Button color = 'danger' onClick={() => setAlertVisibility(true)}>My Butt</Button>
  </div>
)};

export default App;