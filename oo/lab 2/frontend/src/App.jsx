import { useEffect, useState } from 'react';
import './App.css';
const host = 'http://localhost:3000';

function App() {
    const [select, setSelect] = useState(null);
    const [property, setProperty] = useState({
        name: '',
        weight: '',
        extension: '',
    });
    const [files, setFiles] = useState([]);
    const [path, setPath] = useState('D:\\');
    const [subject, setSubject] = useState(null);

    function handleClick(value) {
        if (value.name === select?.name) return;
        setSelect(value);
        setProperty({
            name: value.name,
            weight: value.weight,
            extension:
                value.extension || value.name.split('.').pop() || 'unknown',
        });
    }

    function handleDoubleClick(value) {
        if (value.extension === 'directory') {
            setPath((prev) => prev + '\\' + value.name);
        }
    }

    async function handleKeyDown(e) {
        if (e.key === 'Delete' && select) {
            const fullPath = path + '\\' + select.name;
            try {
                const res = await fetch(
                    host + '/file/remove?fullPath=' + fullPath,
                    { method: 'POST' },
                );
                const data = await res.json();
                if (data.ok || data.message === 'File removed successfully') {
                    setFiles((prev) =>
                        prev.filter((file) => file.name !== select.name),
                    );
                    setSelect(null);
                } else {
                    console.error('Delete failed:', data.message || data);
                }
            } catch (err) {
                console.error('Delete error:', err);
            }
        }

        if (e.ctrlKey || (e.metaKey && select !== null)) {
            switch (e.key) {
                case 'c':
                    navigator.clipboard.writeText(path + '\\' + select.name);
                    setSubject({
                        type: 'copy',
                        value: select,
                        path: path + '\\' + select.name,
                    });
                    break;
                case 'x':
                    navigator.clipboard.writeText(path + '\\' + select.name);
                    setSubject({
                        type: 'cut',
                        value: select,
                        path: path + '\\' + select.name,
                    });
                    break;
                case 'v':
                    if (subject) {
                        let repetitions = 0;
                        let newFilePath = path + '\\' + subject.value.name;
                        let newName = subject.value.name;

                        let existingFile = files.find(
                            (file) => file.name === subject.value.name,
                        );

                        while (existingFile) {
                            newName = subject.value.name;
                            newFilePath = path + '\\' + newName;

                            const additive = repetitions
                                ? `_copy (${repetitions})`
                                : '_copy';
                            if (subject.value.extension === 'directory') {
                                newName = newName + additive;
                                newFilePath = path + '\\' + newName;
                            } else {
                                newName =
                                    newName.split('.').slice(0, -1).join('.') +
                                    additive +
                                    '.' +
                                    subject.value.extension;
                                newFilePath = path + '\\' + newName;
                            }
                            existingFile = files.find(
                                (file) => file.name === newName,
                            );
                            repetitions++;
                        }

                        if (subject.type === 'copy') {
                            console.log(
                                'Copying from',
                                subject.path,
                                'to',
                                newFilePath,
                            );
                            const res = await fetch(
                                host +
                                    '/file/copy?fullPath=' +
                                    encodeURIComponent(subject.path) +
                                    '&newFilePath=' +
                                    encodeURIComponent(newFilePath),
                                { method: 'POST' },
                            );
                            const data = await res.json();
                            if (
                                data.ok ||
                                data.message === 'File copied successfully'
                            ) {
                                setFiles((prev) => [
                                    ...prev,
                                    {
                                        ...subject.value,
                                        name: newName,
                                    },
                                ]);
                            } else {
                                console.error(
                                    'Copy failed:',
                                    data.message || data,
                                );
                            }
                        } else if (subject.type === 'cut') {
                            const res = await fetch(
                                host +
                                    '/file/move?fullPath=' +
                                    encodeURIComponent(subject.path) +
                                    '&newFilePath=' +
                                    encodeURIComponent(newFilePath),
                                { method: 'POST' },
                            );
                            const data = await res.json();
                            if (
                                data.ok ||
                                data.message === 'File moved successfully'
                            ) {
                                setFiles((prev) => [
                                    ...prev,
                                    {
                                        ...subject.value,
                                        name: newName,
                                    },
                                ]);
                            } else {
                                console.error(
                                    'Move failed:',
                                    data.message || data,
                                );
                            }
                        }
                    }
                    break;
                default:
                    break;
            }
        }
    }

    async function handleRename() {
        const oldName = select.name;
        const newName = property.name;
        if (!oldName || !newName || oldName === newName) return;
        try {
            const fullOld = path + '\\' + oldName;
            const fullNew = path + '\\' + newName;
            const res = await fetch(
                host +
                    '/file/rename?fullPath=' +
                    encodeURIComponent(fullOld) +
                    '&newFilePath=' +
                    encodeURIComponent(fullNew),
                { method: 'POST' },
            );
            const data = await res.json();
            if (
                data &&
                (data.ok === false ||
                    data.message !== 'File renamed successfully')
            ) {
                console.error('Rename failed:', data.message || data);
                return;
            }

            try {
                const response = await fetch(
                    host + '/Directory?fullPath=' + path,
                    {
                        method: 'GET',
                    },
                );
                const data = await response.json();
                setFiles(data.files || []);
                handleClick(data.files.find((f) => f.name === newName) || null);
            } catch (err) {
                console.error('Fetch error:', err);
            }
        } catch (err) {
            console.error('Rename error:', err);
        }
    }

    useEffect(() => {
        async function fetchFiles() {
            try {
                const response = await fetch(
                    host + '/Directory?fullPath=' + path,
                    {
                        method: 'GET',
                    },
                );
                const data = await response.json();
                setFiles(data.files || []);
            } catch (err) {
                console.error('Fetch error:', err);
            }
        }
        fetchFiles();
    }, [path]);

    return (
        <div className="main">
            <div className="left-panel">
                <header className="patch">
                    <button
                        onClick={() =>
                            setPath(path.split('\\').slice(0, -1).join('\\'))
                        }
                    >
                        🡰
                    </button>
                    <input
                        type="text"
                        value={path}
                        onChange={(e) => setPath(e.target.value)}
                    />
                </header>
                <div
                    className="explorer"
                    onKeyDown={handleKeyDown}
                    tabIndex={0}
                >
                    {files.map((value) => (
                        <div
                            className={
                                'file ' +
                                (value.name === select?.name ? 'selected' : '')
                            }
                            onClick={() => handleClick(value)}
                            key={value.name}
                        >
                            <img
                                className="icon"
                                src={
                                    '../public/' +
                                    (value.extension === 'directory'
                                        ? 'dir.png'
                                        : 'file.png')
                                }
                                alt="icon"
                                style={{
                                    filter: `invert(100%) sepia(100%) saturate(100%) hue-rotate(${((value.extension ? value.extension.charCodeAt(0) : 'd'.charCodeAt(0)) * 10 + 80) % 360}deg)`,
                                }}
                                onDoubleClick={() => handleDoubleClick(value)}
                            />
                            <p>
                                {value.name.length > 15
                                    ? value.name.substring(0, 15) + '...'
                                    : value.name}
                            </p>
                        </div>
                    ))}
                </div>
            </div>
            <div className="right-panel">
                <div className="property">
                    <h3>Property</h3>
                    <h4>
                        Name:{' '}
                        <input
                            type="text"
                            value={property.name}
                            onChange={(e) =>
                                setProperty((p) => ({
                                    ...p,
                                    name: e.target.value,
                                }))
                            }
                            onKeyDown={(e) => {
                                if (e.key === 'Enter') {
                                    handleRename();
                                }
                            }}
                        />
                    </h4>
                    <h4>Weight: {property.weight}</h4>
                    <h4>Extension: {property.extension}</h4>
                    <p>
                        {property.content && property.content.length > 200
                            ? property.content.substring(0, 100) + '...'
                            : property.content}
                    </p>
                </div>
            </div>
        </div>
    );
}

export default App;
