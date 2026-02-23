import React from 'react';
import styles from './style.module.css';

export default function Panel() {
    const [elements, setElements] = React.useState<string[]>([]);

    return (
        <>
            <div className={styles.panel}>
                <h2 className={styles.title}>Panel</h2>
                <button
                    className={styles.button}
                    onClick={() =>
                        setElements([
                            ...elements,
                            `Element ${elements.length + 1}`,
                        ])
                    }
                >
                    <h3>В Panel можно динамически создавать элементы</h3>
                </button>
                <div className={styles.box}>
                    {elements.map((item) => (
                        <div key={item} className={styles.element}>
                            Я новый элемент №{item}
                        </div>
                    ))}
                </div>
            </div>
        </>
    );
}
