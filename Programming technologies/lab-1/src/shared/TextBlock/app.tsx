import styles from './style.module.css';

export default function TextBlock() {
    function resize(){
        const textarea = document.querySelector('textarea');
        if (textarea) {
            textarea.style.height = 'auto';
            textarea.style.height = textarea.scrollHeight + 'px';
        }
    }

    return (
        <textarea className={styles.input} onInput={resize} placeholder='TextArea'/>
    );
}
