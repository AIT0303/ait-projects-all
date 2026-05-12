import datetime

now = datetime.datetime.now()
print(f"{now:%H：%M：%S}")

print(f"{now:%p %I %M %S}")
      
print(f"{now:%m月 %d日 (%a)}")