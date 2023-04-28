using Godot;
using System;
using System.Collections.Generic;

public class Graph
{
	Dictionary<String, VNode> nodes;


	public void build_graph(Godot.Collections.Dictionary dict)
	{
		nodes = new Dictionary<String, VNode>();
		System.Collections.IDictionaryEnumerator enm = dict.GetEnumerator();

		while (enm.MoveNext())
		{//Looping over all nodes
			String name = (String)enm.Key;
			VNode node = new VNode(name, new List<DestWeightPair>());
			List<DestWeightPair> adjs = new List<DestWeightPair>();
			Godot.Collections.Array dictEdges = (Godot.Collections.Array) dict[name];
			foreach (Godot.Collections.Array edge in dictEdges)
			{
				String str = (String) edge[1];
				float num = (float)edge[0];
				DestWeightPair pair = new DestWeightPair((String)edge[1], (float)edge[0]);
				adjs.Add(pair);
			}
			nodes.Add(name, new VNode(name, adjs));
		}
		int debug = 10;
	}

}


/*
Graph structure:
-Nodes Map: name mapped to Node obj
-Node: name, adjs list
-adjs list: list of DestWeightPairs
-NodeWeightPair: destination node, edge weight

*/









