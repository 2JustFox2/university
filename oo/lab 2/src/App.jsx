import { useState } from 'react';
import './App.css';

const host = 'localhost:3000';

function App() {
    const [select, setSelect] = useState(null);
    const [property, setProperty] = useState({name: '', weight: '', extension: ''});

    async function handleClick(value) {
        // await fetch(host + '/file', {fileName: elem.target.content})

        setSelect(value.name)
        setProperty(value)
    }

    const data = [
        { name: 'file.txt', weight: '100Mb', extension: 'txt' },
        { name: 'file2.txt', weight: '130Mb', extension: 'txt' },
        { name: 'file3.txt', weight: '100Mb', extension: 'txt' },
        { name: 'dir', weight: '1Gb', extension: 'directory' },
    ];

    return (
        <div className="main">
            <div className="left-panel">
                <header className="patch">
                    <input type="text" />
                </header>
                <div className="explorer">
                    {data.map((value, index) => (
                        <div className={value.name === select ? "selected" : "file"} onClick={() => handleClick(value)} key={value.name}>
                            {value.name}
                        </div>
                    ))}
                </div>
            </div>
            <div className="right-panel">
                <div className="property">
                    <h3>Property</h3>
                    <h4>Name: {property.name}</h4> 
                    <h4>Weight: {property.weight}</h4> 
                    <h4>Extension: {property.extension}</h4> 
                </div>
                <div className="actions">
                    <h3>FS</h3>
                    <div className="action">
                        <button>copy</button>
                        <button>confirm</button>
                        <p>filename</p>
                    </div>
                    <div className="action">
                        <button>move</button>
                        <button>confirm</button>
                        <p>filename</p>
                    </div>
                </div>
            </div>
        </div>
    );
}

export default App;
