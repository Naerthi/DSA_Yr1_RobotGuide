**THE BEST IGOR BOT**
==========================


Subtask 1 MATLAB interface
==========================

Main entry point:
    run_subtask1_interface

What this version fixes compared with the earlier draft:
1. Reuses the repository's existing QEOP background map image
   (occupancyMap/SatelliteImageNoLabel.png) instead of showing only the binary grid.
2. Overlays the saved occupancy grid on top of the real map.
3. Includes all required complexity discussion in the UI:
   - linked-list lookup O(n)
   - KD-tree average O(log n), worst O(n)
   - BFS O(V+E)
   - Dijkstra without priority queue O(V^2 + E)
   - Dijkstra with binary-heap priority queue O((V+E)logV)
4. Includes empirical timing benchmarks in a table.
5. Includes both Dijkstra variants in the path-search section.
6. Provides a pool of 10 customizable queries.

Query coverage:
- Path from A to B
- Distance from A to B
- k closest key points from A
- 2 closest key points to waiting area 1
- 2 closest key points to waiting area 2
- Closest key point to A
- Nearest waiting point to A
- Full route: nearest waiting -> A -> B -> nearest waiting
- Compare BFS / Dijkstra / Dijkstra+PQ
- List all key points sorted by distance from A

Notes:
- This code uses the existing extractedPoints.m file so the exact project points stay aligned with the repo.
- This code uses the existing adjacency-list graph for consistency with the project.
- Dijkstra+PQ is implemented with a binary heap in dijkstra_heap.m rather than a linear search over a simple array.


# Subtask 2: Speculative Navigation with GenAI & KD-Tree

## 1. Project Overview
This task demonstrates **Speculative Programming** in a human-robot interaction scenario. The robot "listens" to a real-time conversation between two indecisive people and dynamically recalculates the optimal navigation path as their intentions change.

**Key Features:**
* **GenAI Integration**: Uses `Ollama (Qwen2.5)` to interpret natural language and extract navigation intent.
* **Real-time Processing**: Simulates human speech timestamps to show dynamic path updates.
* **Algorithm Comparison**: Evaluates the efficiency of **Linear Linked List** ($O(n)$) vs. **KD-Tree** ($O(\log n)$) for spatial landmark searching.

---

## 2. Environment Setup (Crucial)

### How to install and launch LLM (Ollama)
The navigation intent extraction requires a local LLM service to be running.

1.  **Download Ollama**: Visit [ollama.com](https://ollama.com/) and install the version for your OS.
2.  **Run the Model**: Open your Terminal (Mac/Linux) or Command Prompt (Windows) and type:

```bash
ollama run qwen2.5
```
Keep it Running: Ensure the terminal window remains open while running the MATLAB script.

3. Algorithm Analysis & Performance
We compared two data structures for searching the 23 topological nodes (Landmarks + Signal Points) in our map.

Linear List (O(n)): The system iterates through every node to find a match. Search time grows linearly with the number of landmarks.

KD-Tree (O(logn)): The system uses spatial partitioning to discard large portions of the search space, resulting in logarithmic search time.

Experimental Results:
During our simulation, the KD-Tree approach demonstrated a significant reduction in latency (approx. 70-80% faster), which is vital for real-time robotic responsiveness as the map scales to larger environments.

4. How to Run
Open MATLAB and navigate to the Subtask_2 folder.

Ensure the following files are in the same directory:

subtask2_main.m (Main Script)

parse_dialogue.m (LLM Interface Function)

newMapReadings.mat (Position Data)

extractedPoints.m & AngularV.m (Dependency Scripts)

Run subtask2_main.m.

Observe the real-time path updates in the figure window as the dialogue progresses at 5s, 12s, and 20s.

Visualisation - Dynamic Obstacles
==========================

Main entry point:
    mainV2.m
