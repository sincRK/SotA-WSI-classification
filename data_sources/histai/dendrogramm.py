import matplotlib.pyplot as plt
from scipy.cluster.hierarchy import dendrogram, linkage
import numpy as np
from collections import defaultdict

# Your hierarchical data
data = {
    'C': {
        'count': 556,
        'children': {
            '43': {
                'count': 66,
                'children': {
                    '5': {'count': 28},
                    '4': {'count': 1},
                    '7': {'count': 9},
                    '3': {'count': 7},
                    '6': {'count': 7},
                    '9': {'count': 1},
                    '0': {'count': 1},
                    '1': {'count': 1},
                    '2': {'count': 3}
                }
            },
            '44': {
                'count': 437,
                'children': {
                    '9': {'count': 1},
                    '4': {'count': 47},
                    '5': {'count': 109},
                    '3': {'count': 111},
                    '6': {'count': 57},
                    '7': {'count': 35},
                    '1': {'count': 13},
                    '2': {'count': 17},
                    '0': {'count': 10},
                    '8': {'count': 1}
                }
            },
            '77': {
                'count': 13,
                'children': {
                    '3': {'count': 5},
                    '4': {'count': 3},
                    '0': {'count': 1},
                    '9': {'count': 1}
                }
            },
            '79': {
                'count': 13,
                'children': {
                    '2': {'count': 5},
                    '8': {'count': 5}
                }
            },
            '02': {
                'count': 2,
                'children': {
                    '1': {'count': 1},
                    '9': {'count': 1}
                }
            },
            '04': {'count': 1},
            '52': {'count': 1},
            '76': {
                'count': 2,
                'children': {
                    '1': {'count': 1}
                }
            },
            '05': {
                'count': 1,
                'children': {
                    '1': {'count': 1}
                }
            },
            '78': {
                'count': 3,
                'children': {
                    '7': {'count': 2}
                }
            },
            '61': {'count': 2},
            '80': {'count': 1},
            '49': {
                'count': 2,
                'children': {
                    '4': {'count': 1},
                    '6': {'count': 1}
                }
            },
            '60': {
                'count': 3,
                'children': {
                    '0': {'count': 1},
                    '8': {'count': 1}
                }
            },
            '06': {
                'count': 1,
                'children': {
                    '0': {'count': 1}
                }
            },
            '34': {
                'count': 1,
                'children': {
                    '2': {'count': 1}
                }
            },
            '00': {
                'count': 2,
                'children': {
                    '4': {'count': 1},
                    '0': {'count': 1}
                }
            },
            '51': {
                'count': 2,
                'children': {
                    '0': {'count': 1},
                    '9': {'count': 1}
                }
            },
            '22': {
                'count': 2,
                'children': {
                    '6': {'count': 2}
                }
            },
            '21': {
                'count': 1,
                'children': {
                    '1': {'count': 1}
                }
            }
        }
    },
    'D': {
        'count': 604,
        'children': {
            '22': {
                'count': 360,
                'children': {
                    '4': {'count': 52},
                    '5': {'count': 97},
                    '7': {'count': 41},
                    '6': {'count': 54},
                    '9': {'count': 3},
                    '3': {'count': 51},
                    '2': {'count': 7},
                    '1': {'count': 5},
                    '0': {'count': 3},
                    '8': {'count': 1}
                }
            },
            '04': {
                'count': 72,
                'children': {
                    '3': {'count': 20},
                    '7': {'count': 5},
                    '0': {'count': 3},
                    '5': {'count': 10},
                    '6': {'count': 9},
                    '4': {'count': 5},
                    '1': {'count': 2},
                    '2': {'count': 2}
                }
            },
            '48': {
                'count': 14,
                'children': {
                    '5': {'count': 11},
                    '1': {'count': 1},
                    '9': {'count': 1}
                }
            },
            '23': {
                'count': 89,
                'children': {
                    '6': {'count': 10},
                    '5': {'count': 22},
                    '4': {'count': 7},
                    '7': {'count': 11},
                    '2': {'count': 3},
                    '3': {'count': 17},
                    '1': {'count': 1},
                    '9': {'count': 1},
                    '0': {'count': 1}
                }
            },
            '21': {
                'count': 6,
                'children': {
                    '0': {'count': 2},
                    '3': {'count': 2},
                    '2': {'count': 1},
                    '9': {'count': 1}
                }
            },
            '10': {
                'count': 6,
                'children': {
                    '6': {'count': 1},
                    '3': {'count': 1},
                    '4': {'count': 1},
                    '5': {'count': 1},
                    '0': {'count': 1}
                }
            },
            '28': {
                'count': 9,
                'children': {
                    '7': {'count': 1},
                    '0': {'count': 1},
                    '1': {'count': 5},
                    '9': {'count': 1}
                }
            },
            '03': {
                'count': 29,
                'children': {
                    '5': {'count': 7},
                    '6': {'count': 3},
                    '4': {'count': 1},
                    '7': {'count': 5},
                    '3': {'count': 6}
                }
            },
            '17': {
                'count': 3,
                'children': {
                    '2': {'count': 1},
                    '1': {'count': 2}
                }
            },
            '12': {
                'count': 2,
                'children': {
                    '5': {'count': 1},
                    '9': {'count': 1}
                }
            },
            '29': {
                'count': 2,
                'children': {
                    '0': {'count': 1},
                    '4': {'count': 1}
                }
            },
            '44': {'count': 1},
            '14': {
                'count': 1,
                'children': {
                    '0': {'count': 1}
                }
            },
            '18': {
                'count': 7,
                'children': {
                    '0': {'count': 7}
                }
            },
            '07': {
                'count': 2,
                'children': {
                    '4': {'count': 1},
                    '1': {'count': 1}
                }
            },
            '05': {'count': 1}
        }
    },
    'L': {
        'count': 244,
        'children': {
            '57': {
                'count': 57,
                'children': {
                    '0': {'count': 56}
                }
            },
            '82': {
                'count': 88,
                'children': {
                    '0': {'count': 1}
                }
            },
            '90': {
                'count': 40,
                'children': {
                    '5': {'count': 40}
                }
            },
            '85': {
                'count': 10,
                'children': {
                    '8': {'count': 5},
                    '9': {'count': 2}
                }
            },
            '30': {
                'count': 7,
                'children': {
                    '9': {'count': 3},
                    '8': {'count': 4}
                }
            },
            '72': {
                'count': 17,
                'children': {
                    '0': {'count': 17}
                }
            },
            '43': {
                'count': 2,
                'children': {
                    '9': {'count': 2}
                }
            },
            '81': {
                'count': 5,
                'children': {
                    '4': {'count': 5}
                }
            },
            '11': {
                'count': 3,
                'children': {
                    '9': {'count': 1},
                    '0': {'count': 2}
                }
            },
            '98': {
                'count': 2,
                'children': {
                    '4': {'count': 1},
                    '8': {'count': 1}
                }
            },
            '02': {
                'count': 3,
                'children': {
                    '0': {'count': 2},
                    '2': {'count': 1}
                }
            },
            '91': {
                'count': 9,
                'children': {
                    '8': {'count': 7},
                    '0': {'count': 2}
                }
            },
            '52': {'count': 1}
        }
    },
    'I': {
        'count': 1,
        'children': {
            '78': {
                'count': 1,
                'children': {
                    '1': {'count': 1}
                }
            }
        }
    },
    'K': {
        'count': 2,
        'children': {
            '62': {'count': 1},
            '22': {
                'count': 1,
                'children': {
                    '7': {'count': 1}
                }
            }
        }
    },
    'A': {
        'count': 9,
        'children': {
            '63': {
                'count': 9,
                'children': {
                    '0': {'count': 7}
                }
            }
        }
    },
    'N': {
        'count': 9,
        'children': {
            '90': {
                'count': 3,
                'children': {
                    '2': {'count': 1},
                    '9': {'count': 1},
                    '1': {'count': 1}
                }
            },
            '47': {'count': 2},
            '84': {
                'count': 2,
                'children': {
                    '2': {'count': 1}
                }
            },
            '87': {
                'count': 2,
                'children': {
                    '2': {'count': 1},
                    '1': {'count': 1}
                }
            }
        }
    },
    'B': {
        'count': 8,
        'children': {
            '07': {'count': 4},
            '08': {
                'count': 4,
                'children': {
                    '1': {'count': 4}
                }
            }
        }
    },
    'Q': {
        'count': 2,
        'children': {
            '82': {
                'count': 2,
                'children': {
                    '5': {'count': 1}
                }
            }
        }
    }
}

def build_dendrogram_data(data):
    """
    Convert hierarchical dictionary to format suitable for scipy dendrogram
    """
    # Collect all nodes with their full paths and counts
    all_nodes = []
    node_counts = {}

    def traverse(node_dict, path="", parent_idx=None):
        for key, value in node_dict.items():
            current_path = f"{path}{key}" if path else key
            count = value['count']

            node_idx = len(all_nodes)
            all_nodes.append(current_path)
            node_counts[current_path] = count

            # If this node has children, traverse them
            if 'children' in value:
                child_indices = []
                for child_key, child_value in value['children'].items():
                    child_idx = traverse({child_key: child_value}, current_path, node_idx)
                    if child_idx is not None:
                        child_indices.append(child_idx)

                return node_idx
            else:
                return node_idx

    # Build the tree structure
    traverse(data)

    # Create linkage matrix for scipy dendrogram
    # For a proper dendrogram, we need to create a distance matrix or linkage matrix
    # Since we have a tree structure, we'll create artificial distances based on hierarchy

    # Get leaf nodes (nodes without children)
    leaf_nodes = []
    internal_nodes = []

    def collect_leaves(node_dict, path=""):
        for key, value in node_dict.items():
            current_path = f"{path}{key}" if path else key
            if 'children' not in value or not value['children']:
                leaf_nodes.append(current_path)
            else:
                internal_nodes.append(current_path)
                collect_leaves(value['children'], current_path)

    collect_leaves(data)

    return all_nodes, node_counts, leaf_nodes, internal_nodes

def create_custom_dendrogram(data):
    """
    Create a custom dendrogram visualization
    """
    fig, ax = plt.subplots(figsize=(15, 10))

    # Calculate positions for visualization
    y_positions = {}
    x_positions = {}
    level_counts = defaultdict(int)

    def assign_positions(node_dict, level=0, x_start=0):
        current_x = x_start
        level_nodes = []

        for key, value in node_dict.items():
            count = value['count']
            node_name = key

            if 'children' in value and value['children']:
                # Internal node - position based on children
                child_x_positions = []
                child_x = current_x

                for child_key, child_value in value['children'].items():
                    child_positions = assign_positions({child_key: child_value}, level + 1, child_x)
                    child_x_positions.extend([pos[1] for pos in child_positions])
                    child_x = max(child_x_positions) + 1

                # Position internal node at center of children
                if child_x_positions:
                    node_x = (min(child_x_positions) + max(child_x_positions)) / 2
                else:
                    node_x = current_x
                    current_x += 1
            else:
                # Leaf node
                node_x = current_x
                current_x += 1

            y_positions[node_name] = level
            x_positions[node_name] = node_x
            level_nodes.append((node_name, node_x))

            # Draw connections to children
            if 'children' in value and value['children']:
                for child_key, child_value in value['children'].items():
                    child_x = x_positions.get(child_key, node_x)
                    child_y = level + 1

                    # Line thickness based on count (normalized)
                    max_count = max(node_counts.values()) if 'node_counts' in globals() else count
                    thickness = max(0.5, (count / max_count) * 5)

                    # Draw vertical line from parent to child level
                    ax.plot([node_x, node_x], [level, child_y], 'b-', linewidth=thickness, alpha=0.7)
                    # Draw horizontal line to child
                    ax.plot([node_x, child_x], [child_y, child_y], 'b-', linewidth=thickness, alpha=0.7)
                    # Draw vertical line to child node
                    ax.plot([child_x, child_x], [child_y, child_y], 'b-', linewidth=thickness, alpha=0.7)

        return level_nodes

    # Build positions and draw
    all_nodes, node_counts, leaf_nodes, internal_nodes = build_dendrogram_data(data)
    assign_positions(data)

    # Add node labels
    for node_name in x_positions:
        x = x_positions[node_name]
        y = y_positions[node_name]
        count = node_counts.get(node_name, 0)

        # Add node point
        ax.plot(x, y, 'ro', markersize=8, zorder=5)
        # Add label with count
        ax.annotate(f'{node_name}\n({count})', (x, y), xytext=(5, 5),
                   textcoords='offset points', fontsize=8, ha='left')

    ax.set_xlabel('Nodes')
    ax.set_ylabel('Hierarchy Level')
    ax.set_title('Hierarchical Structure Dendrogram\n(Line thickness represents count values)')
    ax.grid(True, alpha=0.3)
    ax.invert_yaxis()  # Root at top

    plt.tight_layout()
    plt.show()

def create_scipy_dendrogram(data):
    """
    Alternative approach using scipy's dendrogram with artificial distance matrix
    """
    # Get all leaf nodes for distance matrix approach
    all_nodes, node_counts, leaf_nodes, internal_nodes = build_dendrogram_data(data)

    if len(leaf_nodes) < 2:
        print("Need at least 2 leaf nodes for scipy dendrogram")
        return

    # Create a simple linkage matrix (this is a simplified approach)
    # In practice, you might want to use actual distances between your data points
    n_leaves = len(leaf_nodes)

    # Create artificial linkage matrix
    # Format: [idx1, idx2, distance, cluster_size]
    linkage_matrix = []

    # Simple approach: create hierarchical clustering based on alphabetical order
    # This is just for demonstration - you might want more sophisticated clustering
    for i in range(n_leaves - 1):
        linkage_matrix.append([i, i + 1, i + 1, 2])

    linkage_matrix = np.array(linkage_matrix)

    # Create dendrogram
    plt.figure(figsize=(12, 8))

    # Custom color and line width functions
    def get_line_width(cluster_id):
        # This would need to be mapped to your actual count data
        return 2.0  # Default thickness

    dend = dendrogram(linkage_matrix,
                     labels=leaf_nodes[:len(linkage_matrix) + 1],
                     leaf_rotation=90)

    plt.title('Scipy Dendrogram (Simplified)')
    plt.xlabel('Nodes')
    plt.ylabel('Distance')
    plt.tight_layout()
    plt.show()

# Run the visualization
print("Creating custom dendrogram...")
create_custom_dendrogram(data)
create_scipy_dendrogram(data)

print("\nNode counts summary:")
all_nodes, node_counts, leaf_nodes, internal_nodes = build_dendrogram_data(data)
for node, count in sorted(node_counts.items()):
    print(f"{node}: {count}")
