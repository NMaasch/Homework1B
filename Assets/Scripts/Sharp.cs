using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Sharp : MonoBehaviour
{
    Renderer render;

    void Start()
    {
        render = GetComponent<Renderer>();

        render.material.shader = Shader.Find("Custom/Sharpen");
    }

    // Update is called once per frame
    void Update()
    {
        //update the shader with positions of the mouse
        render.material.SetFloat("_mX", Input.mousePosition.x);
        render.material.SetFloat("_mY", Input.mousePosition.y);

    }
}
