using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;


public enum GameState
{
    Playing,
    OnMenu
}

public class GameManager : MonoBehaviour
{
    public static GameManager instance;

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



    public void QuitGame()
    {
        Application.Quit();
    }
}
