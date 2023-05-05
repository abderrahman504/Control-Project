using Godot;
using System;
using System.Collections.Generic;

public class VNode : Reference
{
	public String name;
	public List<DestWeightPair> adjacents;

	public VNode(String name, List<DestWeightPair> adjacents)
	{
		this.name = name;
		this.adjacents = adjacents;
	}
}
