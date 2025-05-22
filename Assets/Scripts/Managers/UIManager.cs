using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIManager : MonoBehaviour
{
    public static UIManager instance;
    Canvas canvas;
    [SerializeField] GameObject pauseMenu;
    HealthUIController healthUIController;
    BossHealthUIController bossHealthUIController;


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
            bossHealthUIController = canvas.gameObject.transform.GetComponentInChildren<BossHealthUIController>();
        }
    }


    public void HealthChanged(float newValue)
    {
        if (healthUIController == null) {Debug.LogError("No healthUIController found!"); return; }
        healthUIController.ChangeHealthUIValue(newValue);
    }


    public void BossHealthChanged(float newValue)
    {
        if (bossHealthUIController == null) return;
        bossHealthUIController.HealthChanged(newValue);
    }


    public void RequestPauseMenuActivation(bool request)
    {
        pauseMenu.SetActive(request);
    }
}
