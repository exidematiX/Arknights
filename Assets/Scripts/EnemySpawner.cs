using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemySpawner : MonoBehaviour
{
    public static EnemySpawner Instance { get; private set; }

    public Transform startPoint;
    public List<Wave> waveList;

    private int enemyCount = 0;

    private Coroutine spawnCoroutine;

    private void Awake()
    {
        Instance = this;
    }
    // Start is called before the first frame update
    void Start()
    {
        spawnCoroutine =  StartCoroutine(SpawnEnemy());
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    IEnumerator SpawnEnemy()
    {
        foreach(Wave wave in waveList)
        {
            for(int i = 0; i < wave.count; i++)
            {
                GameObject.Instantiate(wave.enemyPrefab,startPoint.position,Quaternion.identity);
                enemyCount++;
                if (i != wave.count - 1)
                {
                    yield return new WaitForSeconds(wave.rate);
                }
            }
            while (enemyCount > 0)
            {
                yield return 0;
            }

        }
        yield return null;

        while (enemyCount > 0)
        {
            yield return 0;
        }
        GameManager.Instance.Win();
    }
    public void StopSpawn()
    {
        StopCoroutine(spawnCoroutine);
    }

    public void DecreateEnemyCount()
    {
        if (enemyCount > 0)
        {
            enemyCount--;
        }
    }
}
