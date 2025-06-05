import json
import os
import sys

class PlanNode:
    def __init__(self, node_type, cardinality):
        self.type = node_type
        self.cardinality = cardinality
        self.joinsize = -1

class SeqScanNode(PlanNode):
    def __init__(self, table, cardinality):
        super().__init__("SEQ_SCAN", cardinality)
        self.table = table
        self.children = []  # Initialize children list

    def __repr__(self):
        return f"SeqScanNode(table={self.table}, cardinality={self.cardinality}, joinsize={self.joinsize})"

class ComparisonJoinNode(PlanNode):
    def __init__(self, children, cardinality):
        super().__init__("COMPARISON_JOIN", cardinality)
        self.children = children

    def __repr__(self):
        return f"ComparisonJoinNode(cardinality={self.cardinality}, children={self.children}, joinsize={self.joinsize})"

def extract_tree(node):
    node_name = node.get("name", "").strip()
    if node_name == "SEQ_SCAN":
        return SeqScanNode(
            table=node.get("extra_info", {}).get("Table"),
            cardinality=node.get("extra_info", {}).get("Estimated Cardinality")
        )
    elif node_name == "COMPARISON_JOIN" or node_name == "HASH_JOIN":
        children = []
        for child in node.get("children", []):
            t = extract_tree(child)
            if t:
                children.append(t)
        return ComparisonJoinNode(
            children=children,
            cardinality=node.get("extra_info", {}).get("Estimated Cardinality")
        )
    else:
        for child in node.get("children", []):
            t = extract_tree(child)
            if t:
                return t
        return None

def replace_join_with_max_seqscan(node):
    """DFS replacement: replace join nodes with max cardinality SeqScan as root"""
    if isinstance(node, SeqScanNode):
        return node
    elif isinstance(node, ComparisonJoinNode):
        # Check if all children are SeqScan nodes
        join_cardinality = node.cardinality
        all_seqscan = len(node.children) > 0 and all(isinstance(child, SeqScanNode) for child in node.children)
        
        if all_seqscan:
            def get_comparison_value(x):
                return int(x.joinsize) if x.joinsize != -1 else int(x.cardinality)
            
            max_seqscan = max(node.children, key=get_comparison_value)
            max_seqscan.joinsize = join_cardinality  # Set the join size to the join's cardinality
            # Make other children become children of the max cardinality SeqScan
            max_seqscan.children = [child for child in node.children if child != max_seqscan]
            return max_seqscan
        else:
            # Not all children are SeqScan, recursively process children first
            processed_children = []
            for child in node.children:
                processed_children.append(replace_join_with_max_seqscan(child))
            
            # Now find the SeqScan node with maximum cardinality among processed children
            max_seqscan = None
            max_cardinality = -1
            
            for child in processed_children:
                if isinstance(child, SeqScanNode):
                    child_value = int(child.joinsize) if child.joinsize != -1 else int(child.cardinality)
                    if child_value > max_cardinality:
                        max_cardinality = child_value
                        max_seqscan = child
            
            if max_seqscan:
                # Make other children become children of the max cardinality SeqScan
                max_seqscan.children.extend([child for child in processed_children if child != max_seqscan])
                max_seqscan.joinsize = join_cardinality  # Update cardinality to join's cardinality
                return max_seqscan
            
            # return processed_children[0] if processed_children else None
    return None

def tree_to_json(node):
    """Convert tree to JSON format with only relation and children"""
    if isinstance(node, SeqScanNode):
        json_node = {
            "relation": node.table,
            "children": []
        }
        for child in node.children:
            json_node["children"].append(tree_to_json(child))
        return json_node
    return None

def print_tree(node, indent=0):
    spaces = "  " * indent
    if isinstance(node, SeqScanNode):
        if len(node.children) > 0:
            print(f"{spaces}Table: {node.table}, Cardinality: {node.cardinality}, Join Size: {node.joinsize}")
            for child in node.children:
                print_tree(child, indent + 1)
        else:
            print(f"{spaces}Table: {node.table}, Cardinality: {node.cardinality}, Join Size: {node.joinsize} (Leaf Node)")
    elif isinstance(node, ComparisonJoinNode):
        print(f"{spaces}Join, Cardinality: {node.cardinality}, Join Size: {node.joinsize}")
        for child in node.children:
            print_tree(child, indent + 1)

def main(base_path=None):
    if base_path is None:
        base_path = "/"
    
    input_file = os.path.join(base_path, "db_plan.json")
    output_file = os.path.join(base_path, "plan.json")
    
    with open(input_file) as f:
        plan = json.load(f)

    tree = extract_tree(plan[0])
    # print_tree(tree)
    simplified_tree = replace_join_with_max_seqscan(tree)
    # print_tree(simplified_tree)
    
    # Convert to JSON format
    json_tree = tree_to_json(simplified_tree)
    
    # Output JSON to file
    with open(output_file, "w+") as f:
        json.dump(json_tree, f, indent=2)
    # print(f"\nJSON plan saved to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        main(sys.argv[1])
    else:
        main()