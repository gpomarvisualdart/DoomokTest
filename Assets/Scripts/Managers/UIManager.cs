using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIManager : MonoBehaviour
{
    public static UIManager instance;
    [SerializeField] GameObject canvas;
    [SerializeField] GameObject pauseMenu;
    [SerializeField] GameObject gameOverScreen;
    [SerializeField] GameObject numOfTries;
    HealthUIController healthUIController;
    BossHealthUIController bossHealthUIController;
    TriesUIController triesUIController;

    private bool isPaused;
    public bool GetIsPaused() { return isPaused; }


    private void Awake()
    {
        if (instance != null) return;
        instance = this;
    }


    private void OnEnable()
    {
        if (canvas == null)
        {
            healthUIController = canvas.gameObject.transform.GetComponentInChildren<HealthUIController>();
            if (healthUIController == null) { Debug.LogError("No healthUIController found!"); return; }
            bossHealthUIController = canvas.gameObject.transform.GetComponentInChildren<BossHealthUIController>();
            triesUIController = canvas.gameObject.transform.GetComponent<TriesUIController>();
            return;
        }

        isPaused = false;
        healthUIController = canvas.gameObject.transform.GetComponentInChildren<HealthUIController>();
        if (healthUIController == null) { Debug.LogError("No healthUIController found!"); return; }
        bossHealthUIController = canvas.gameObject.transform.GetComponentInChildren<BossHealthUIController>();
        triesUIController = canvas.gameObject.transform.GetComponentInChildren<TriesUIController>();
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
        isPaused = request;
    }


    public void RequestActivateGameOver(bool req)
    {
        gameOverScreen.SetActive(req);
    }


    public void AddTries()
    {
        triesUIController.UpdateTries();
    }


    public void ResetTries()
    {
        triesUIController.RestartTries();
    }
}
