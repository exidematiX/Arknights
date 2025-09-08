using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    private int _currentHealth = 0;
    public int CurrentHealth
    {
        get { return _currentHealth; }
        set
        {
            _currentHealth = Mathf.Clamp(value, 0, maxHealth);
            
            healthText.text = _currentHealth <= 1 ? $"<color=red>HP: {_currentHealth}</color>" : $"HP: {_currentHealth}";
            if (_currentHealth <= 0)
            {
                _currentHealth = 0;
                Fail();
            }
        }
    }
    public int maxHealth = 5;

    [Header("组件引用")]
    public TextMeshProUGUI healthText;

    public GameEndUI gameEndUI;

    private void Awake()
    {
        Instance = this;
    }
    
    private void Start()
    {
        CurrentHealth = maxHealth;
    }

    public void Fail()
    {
        EnemySpawner.Instance.StopSpawn();
        gameEndUI.Show("ʧ ��");
    }
    public void Win()
    {
        gameEndUI.Show("ʤ ��");
    }

    public void OnRestart()
    {
        CurrentHealth = maxHealth;
        SceneManager.LoadScene( SceneManager.GetActiveScene().buildIndex ) ;
    }
    public void OnMenu()
    {
        SceneManager.LoadScene(0);
    }
}
