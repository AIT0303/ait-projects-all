import datetime

def stopwatch2():
    now = datetime.datetime.now()
    print(f"現在 = {now:%d %a %H %M %S}"),
    goal = now.replace(day=29, hour=23, minute=59, second=59)
    print(f"目標 = {goal:%d %a %H %M %S}")
    td = goal - now
    print(td)

stopwatch2()




"""
def stopwatch():
    start = datetime.datetime.now()
    input("Enterキーを押してください")
    now = datetime.datetime.now()
    td = now - start
    print(td)

stopwatch()
"""



