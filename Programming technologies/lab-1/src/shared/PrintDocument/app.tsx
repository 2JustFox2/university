import styles from './style.module.css';

export default function PrintDocument() {
    return (
        <>
            <button className={styles.button} onClick={() => print()}>
                <h3>PrintDocument</h3>
            </button>
        </>
    );
}
