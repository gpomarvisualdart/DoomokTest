using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIManager : MonoBehaviour
{
    public static UIManager instance;
    Canvas canvas;
    HealthUIController healthUIController;


    private void Awake()
    {
        if (instance != null) return;
        instance = this;
    }


    private void OnEnable()
    {
        if (canvas == null)
        {
            canvas = FindObjectOfType<Canvas>();
            healthUIController = canvas.gameObject.transform.GetComponentInChildren<HealthUIController>();
            if (healthUIController == null) { Debug.LogError("No healthUIController found!"); return; } 
        }
    }


    public void HealthChanged(float newValue)
    {
        if (healthUIController == null) {Debug.LogError("No healthUIController found!"); return; }
        healthUIController.ChangeHealthUIValue(newValue);
    }
}
