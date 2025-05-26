using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;


public enum GameState
{
    Playing,
    OnMenu,
    GameOver
}

public class GameManager : MonoBehaviour
{
    public static GameManager instance;
    [SerializeField] Transform retryPosition;

    GameState currentGameState;

    private void Awake()
    {
        if (instance != null) return;
        instance = this;
        currentGameState = GameState.Playing;
        Time.timeScale = 1f;
    }


    public void RequestPause()
    {
        if (currentGameState == GameState.Playing)
        {
            Time.timeScale = 0;
            currentGameState = GameState.OnMenu;
            UIManager.instance.RequestPauseMenuActivation(true);
        }
        else
        {
            Time.timeScale = 1f;
            currentGameState = GameState.Playing;
            UIManager.instance.RequestPauseMenuActivation(false);
        }
    }



    public void RestartGame()
    {
        SceneManager.LoadSceneAsync("SampleScene", LoadSceneMode.Single);
    }



    public void ActivateGameOverScreen()
    {
        if (currentGameState != GameState.GameOver)
        {
            UIManager.instance.RequestActivateGameOver(true);
            Time.timeScale = 0;
            currentGameState = GameState.GameOver;
        }
        else
        {
            UIManager.instance.RequestActivateGameOver(false);
            Time.timeScale = 1f;
            currentGameState = GameState.Playing;
        }
    }


    public void RetryGame()
    {
        LogicPlayer plr = FindObjectOfType<LogicPlayer>();
        if (plr == null) { Debug.LogError("No player logic!"); return; }
        ActivateGameOverScreen();
        UIManager.instance.AddTries();
        plr.ReloadPlayer();
        plr.GetPlayerTransform().position = retryPosition.position;
    }


    public void OnPlayerDeath()
    {
        if (UIManager.instance.GetIsPaused() && currentGameState == GameState.OnMenu && Time.timeScale == 0f) return;
        ActivateGameOverScreen();
    }


    public void QuitGame()
    {
        Application.Quit();
    }
}
