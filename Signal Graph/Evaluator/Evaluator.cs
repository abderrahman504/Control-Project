using Godot;
using System;

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
	public void Initialize(Godot.Collections.Dictionary graphDict)
	{
		Graph graph = new Graph();
		graph.build_graph(graphDict);
	}
}
