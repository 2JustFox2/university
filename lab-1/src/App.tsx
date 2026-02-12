import './App.css';
import { Panel, PrintDocument, TextBlock } from './shared';

function App() {
    return (
        <>
            <div className="main">
                <h1>Lab 1</h1>
                <h2>Оконное приложение на React + Vite</h2>
                <TextBlock />
                <PrintDocument />
                <Panel />
            </div>
        </>
    );
}

export default App;
