using Godot;
using System;
using System.Collections.Generic;
using System.Linq;


public class Evaluator : Reference
{
	
//  Graph in dict form:
//  {
//  	x1: [[gain, dest_node.name], [gain, dest_node.name], [gain, dest_node.name]]  
//  	x2: ...
//  	x3: ...
//  	x4: ...
//  	R: ...
//  	C: ...
//  }
	public void Initialize(Godot.Collections.Dictionary graphDict, WindowDialog solWindow)
	{
		var paths = FindAllPaths(graphDict);
		var loops = FindAllLoops(graphDict);
		double solution = Mason(graphDict, paths, loops, solWindow);
	}
	

	public List<List<string>> FindAllPaths(Godot.Collections.Dictionary graph, string start="R", string end="C", List<string> path=null, HashSet<string> visited=null)
	{
		if (path == null) path = new List<string>();
		path.Add(start);

		if (start == end) return new List<List<string>>() { new List<string>(path) };
		if (!graph.Contains(start)) return new List<List<string>>();

		if (visited == null) visited = new HashSet<string>();
		visited.Add(start);

		var paths = new List<List<string>>();

		Godot.Collections.Array START_NODE = ((Godot.Collections.Array) graph[start]);
		for (int i = 0; i < START_NODE.Count; i++) {
			var nextNode = (string) ((Godot.Collections.Array) START_NODE[i])[1];
			if (visited.Contains(nextNode)) continue;
			var newPath = FindAllPaths(graph, nextNode, end, new List<string>(path), new HashSet<string>(visited));
			foreach (var p in newPath)
			{
				paths.Add(p);
			}
		}

		return paths;
	}
	
	public List<List<string>> FindAllLoops(Godot.Collections.Dictionary graph, string start="R", HashSet<string> visited = null, List<string> path = null)
	{
		if (visited == null) visited = new HashSet<string>();
		if (path == null) path = new List<string>();

		var loops = new List<List<string>>();

		visited.Add(start);
		path.Add(start);

		if (!graph.Contains(start))
		{
			return loops;
		}

		var neighbors = (Godot.Collections.Array)graph[start];

		foreach (Godot.Collections.Array neighbor in neighbors)
		{
			var nextNode = (string)neighbor[1];

			if (visited.Contains(nextNode))
			{
				var cycle = new List<string>(path);
				cycle.Add(nextNode);
				cycle = cycle.SkipWhile(n => n != nextNode).ToList();
				if (cycle.Count > 1)
				{
					loops.Add(cycle);
				}
			}
			else
			{
				var newPath = new List<string>(path);
				var newVisited = new HashSet<string>(visited);
				var newLoops = FindAllLoops(graph, nextNode, newVisited, newPath);
				loops.AddRange(newLoops);
			}
		}

		visited.Remove(start);

		return loops;
	}
	
	public bool isTouchingLoop(List<string> loop1, List<string> loop2){
		foreach (string node in loop1){
			if (loop2.Contains(node)) return true;
		}
		return false;
	}
	
	
	public int getPathGain(Godot.Collections.Dictionary graphDict, List<string> path){
		int PathGain = 1;
		
		for (int i=0; i<path.Count-1; i++){
			string from_node = path[i];
			string to_node = path[i+1];
			foreach (Godot.Collections.Array node in (Godot.Collections.Array) graphDict[from_node]) {
				if ((string)node[1] == (string)to_node) {
					PathGain *= Convert.ToInt32(node[0]);
				}
			}
		}
		return PathGain;
	}
	
	public double Mason(Godot.Collections.Dictionary graphDict, List<List<string>> paths, List<List<string>> loops, WindowDialog solWindow){
		int K = paths.Count;
		int sum = 0; // Σk (Tk . Δk)

		string SolutionText = "";
		int index = 0;
		SolutionText += "> Forward Paths:\n";
		foreach (List<string> path in paths){
			index += 1;
			SolutionText += index + ") ";
			foreach (string node in path){
				SolutionText += node + " ";
			}
			SolutionText += "[Gains: "+ getPathGain(graphDict, path) +"]\n";
		}
		
		SolutionText += "\n> Individual Loops:\n";
		index = 0;
		foreach (List<string> loop in loops){
			index += 1;
			SolutionText += index + ") ";
			foreach (string node in loop){
				SolutionText += node + " ";
			}
			SolutionText += "[Gains: "+ getPathGain(graphDict, loop) +"]\n";
		}
		if (index == 0) SolutionText += "None\n";
		SolutionText += "\n";
		
		for (int i=0; i<K; i++){
			int T = getPathGain(graphDict, paths[i]);
			int NonTouchingLoops_TotalGain = 0;
			foreach (List<string> loop in loops){
				if (!isTouchingLoop(paths[i], loop)) {
					NonTouchingLoops_TotalGain += getPathGain(graphDict, loop);
				}
			}
			
			SolutionText += "K["+(i+1).ToString()+"]: (d = " + (1-NonTouchingLoops_TotalGain).ToString() + ") (T = " + T + ")\n";
			sum += T * (1-NonTouchingLoops_TotalGain);
		}
		SolutionText += "\n";
		
		int Loops_TotalGain = 0;
		foreach (List<string> loop in loops){
			Loops_TotalGain += getPathGain(graphDict, loop);
		}
		
		int delta = 1 - Loops_TotalGain;
		int sign = 1;
		
		for (int i=2; i<=loops.Count; i++){
			string NonTouchingLoops = "";
			int TotalGain = 0;
			int TotalLoops = 0;
			index = 0;
			for (int j=0; j<loops.Count; j++){
				foreach (List<string> loop in loops){
					if (!isTouchingLoop(loop, loops[j])) {
						TotalLoops += 1;
						TotalGain *= getPathGain(graphDict, loop);
						if (NonTouchingLoops != "") NonTouchingLoops += " | ";
						else {
							index += 1;
							NonTouchingLoops += index + ") ";
						}
						foreach (string node in loop){
							NonTouchingLoops += node + " ";
						}
						if (TotalLoops == i) break;
					}
				}
				if (TotalLoops == i){
					delta += sign * TotalGain;
					sign *= -1;
					SolutionText += "> Non Touching Loops (Taking "+i+" at time):\n";
					SolutionText += NonTouchingLoops + "[Gains: "+TotalGain+"]";
				}
			}
		}
		SolutionText += "\n";
		
		double solution = sum / delta;
		
		// Solution Window
		
		SolutionText += "\n> Transfer Function = " + solution + " | SUM: " + sum + " | delta: " + delta;
		
		solWindow.Popup_();
		solWindow.GetNode<TextEdit>("SolutionBox").Text = SolutionText;
		
		return solution;
	}
}
