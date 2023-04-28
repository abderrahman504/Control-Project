using System;
using Godot;


public class DestWeightPair : Reference
{
	public String dest;
	public float weight;

	public DestWeightPair(String dest, float weight)
	{
		this.dest = dest;
		this.weight = weight;
	}
}