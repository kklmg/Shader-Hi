﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SendPlayerPos : MonoBehaviour
{
    public Transform player;
    public Material blockMat;

	void Start () {
        
	}
	
	void Update ()
    {
        blockMat.SetVector("_PlayerPos", player.position);
    }
}