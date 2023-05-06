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
		int solution = Mason(graphDict, paths, loops);
		solWindow.Popup_();
		solWindow.GetNode<Label>("SolLabel").Text = "Transfer Function = " + solution;
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
	
	public int Mason(Godot.Collections.Dictionary graphDict, List<List<string>> paths, List<List<string>> loops){
		int K = paths.Count;
		int sum = 0; // Σk (Tk . Δk)
		
		GD.Print("Total Paths (K): ", K);
		
		for (int i=0; i<K; i++){
			int T = getPathGain(graphDict, paths[i]);
			int NonTouchingLoops_TotalGain = 0;
			foreach (List<string> loop in loops){
				if (!isTouchingLoop(paths[i], loop)) {
					NonTouchingLoops_TotalGain += getPathGain(graphDict, loop);
				}
			}
			
			GD.Print("T: ", T);
			GD.Print("Δk: ", 1-NonTouchingLoops_TotalGain);
			sum += T * (1-NonTouchingLoops_TotalGain);
		}
		
		int Loops_TotalGain = 0;
		foreach (List<string> loop in loops){
			Loops_TotalGain = getPathGain(graphDict, loop);
		}
		
		int delta = 1 - Loops_TotalGain;
		int sign = 1;
		
		for (int i=2; i<loops.Count; i++){
			for (int j=0; j<loops.Count; j++){
				int TotalGain = 0;
				int TotalLoops = 0;
				foreach (List<string> loop in loops){
					if (!isTouchingLoop(loop, loops[j])) {
						TotalLoops += 1;
						TotalGain += getPathGain(graphDict, loop);
						if (TotalLoops == i) break;
					}
				} 
				if (TotalLoops == i){
					delta += sign * TotalGain;
					sign *= -1;
				}
			}
		}
		
		GD.Print("Δ: ", delta);
		int solution = sum / delta;
		GD.Print("Final Solution: ", solution);
		return solution;
	}
}
