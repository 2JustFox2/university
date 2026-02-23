import React from 'react';
import styles from './style.module.css';

interface TreeNodeType {
    id: number;
    name: string;
    children?: TreeNodeType[];
    active?: boolean;
}

function TreeNode({ node }: { node: TreeNodeType }) {
    const [expanded, setExpanded] = React.useState(false);
    
    return (
        <div className={styles.node}>
            <div className={styles.nodeContent} onClick={() => setExpanded(!expanded)}>
                {`${node.children ? (expanded ? '▼' : '▶') : '▸'} ${node.name}`}
            </div>
            {node.children && expanded && (
                <div className={styles.children}>
                    {node.children.map((child: TreeNodeType) => (
                        <TreeNode key={`${child.id}`} node={child} />
                    ))}
                </div>
            )}
        </div>
    );
}

export default function TreeView() {

    const data = {
        id: 1,
        name: 'Root',
        children: [
            {
                id: 2,
                name: 'Child 1',
                children: [
                    { id: 4, name: 'Grandchild 1' },
                    { id: 5, name: 'Grandchild 2' },
                ],
            },
            { id: 3, name: 'Child 2', children: [
                { id: 6, name: 'Grandchild 3' },
            ] },
        ],
    };

    return (
        <div className={styles.treeView}>
            <TreeNode node={data} />
        </div>
    );
}
