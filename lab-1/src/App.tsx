import './App.css';
import { Panel, PrintDocument, TextBlock, TreeView } from './shared';
import Decimal from 'decimal.js';

class AppState {
    double: number = 12.34;
    readonly decimal: Decimal = new Decimal(12.34);
    uint: Uint16Array = new Uint16Array(1);

    Enum = {
        First: 1,
        Second: 2,
        Third: 3
    };

    constructor() {
        this.uint[0] = 12345;
    }
}
function App() {
    const app = new AppState();
    console.log(app)
    return (
        <>
            <div className="main">
                <h1>Lab 1</h1>
                <h2>Оконное приложение на React + Vite</h2>
                <TextBlock />
                <PrintDocument />
                <Panel />
                <TreeView />
            </div>
        </>
    );
}

export default App;
