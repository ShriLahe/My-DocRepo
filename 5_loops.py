for i in range(0,10,1):
    print(i)
    print("Next No-")

list_of_envs=["dev","qa","prod"]

for env in list_of_envs:
    if env == "dev":
        print("I am in dev")