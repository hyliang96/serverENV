# 集群批量管理工具

梁浩宇   hyliang96@163.com    hyliang96@github

## 介绍

这是一个批量管理集群的小工具

**功能**：

* 可以将机器编组

* 对一个组内每台机器并行地执行命令(一到多条、非交互式命令)，并按机器编号将每台机器的返回排序。

  包括不限于以下操作：

  * 显示所有gpu服务器的显卡使用情况
  * 在所有服务器上创建、查看、删除账号

**支持终端**：`zsh`或`bash`

**支持用户**: 普通用户和root用户

**原理**：并行ssh访问各台服务器

**性能：**比另一个常见的批量管理工具`ansible`快，经测试，查看所有gpu服务器的`gpustat`，本包需要7-9秒，`ansible`需要70-80秒。但本包目前功能比它少。

## 使用方法

### 加载本工具包

使用工具包前，需先在`zsh`或`bash`下执行以下命令

```bash
. <本目录>/load_all.sh
```

### 执行命令

对一个组内每台机器并行地执行命令

```bash
all [机器编组] '命令1' '命令2' '命令3' # 编组不可缺省，用单引号表示不转义，用双引号表示要不转义
```

* 可以执行一到多条命令
* 只能执行非交互式命令
* 返回：按机器编号将每台机器的返回排序

例如，

```bash
all c 'echo yes'
```

> ```
> echo yes
> ====== juncluster1 ======
> # echo yes
> yes
>
> ====== juncluster2 ======
> # echo yes
> yes
>
> ====== juncluster3 ======
> # echo yes
> yes
>
> ====== juncluster4 ======
> # echo yes
> yes
> ```

### 查看gpu使用

```bash
allgpu [机器编组]
```

编组可以缺省，默认编组为所有gpu服务器

### 用户管理

```bash
sudo su # 然后输入密码
. <本目录>/load_all.sh # 加载工具包
```

#### 创建用户

##### 交互界面，使用明码设置用户密码
* 生成随机明码用户密码

  ```bash
  openssl rand -base64 24 # 64位电脑，长为24的随机字符串；此加密方式及linux系统的用户密码加密方式
  ```

  > iFLIklLJejU1uQ1U/V81m0mbXvQbOu9O

* 将此明码复制下来以供后面设置

  * 设置本机

  ```bash
  $(adduser_command)
  ```

  * 设置一整个编组

  ```bash
  all [机器编组] "$(adduser_command)" # 必需是双引号，编组不可缺省
  ```

  交互界面

  > set username: 用户名
  > set realname: 用户真名
  > set uid: 集群上的uid要统一 以便mfs权限正确
  > set password: 明码用户密码
  > check password: 明码用户密码

  然后在每一台服务器上开始创建账号

##### 非交互命令，使用加密的用户密码

* 设置本机

  ```bash
  $(adduser_command -n '用户名' '用户真名' 统一的UID '加密用户密码' ) # 内侧用单引号表示不转义，用双引号表示要不转义
  ```

* 设置一整个编组

  ```bash
  all [机器编组] "$(adduser_command -n '用户名' '用户真名' 统一的UID '加密用户密码' )"  # 外侧必需是双引号； 内侧用单引号表示不转义，用双引号表示要不转义；编组不可缺省
  ```

其中`统一的UID` `加密用户密码`有两种获得方式：

* 当已经在一些机器上创建了这个用户的账号时，为了使得其他机器新建账号的UID和用户密码，与旧机器上的一致，需要用本法设置：

  * UID：在旧机器上

    ```bash
    id 用户名
    ```

    > uid=11328(用户名) gid=11328(组名) groups=11328(组名)
    >
    > ​	↑
    >
    >  此即所求UID

  * 加密用户密码：在旧机器上

    ```bash
    sudo cat /etc/shadow | grep 用户名
    ```

    >  `用户名:$6$xDasasdSDsS1$hJNcEpsSDdP23SosSdzs.j3rHFToIHIH878bsS3w/fyVgnRnZ4/sdasisUlf7AA/3K1ENIJ2asiIIdsd9sSCxxgFsdSAQPa.:17266:0:99999:7:::`

    以冒号分隔，其中第二字段`$6$xDasasdSDsS1$hJNcEpsSDdP23SosSdzs.j3rHFToIHIH878bsS3w/fyVgnRnZ4/sdasisUlf7AA/3K1ENIJ2asiIIdsd9sSCxxgFsdSAQPa. `即加密用户密码

* 当明码用户密码已经知道时，还可以这样获得加密用户密码

  ```bash
  echo 明码用户密码 | openssl passwd -1 -stdin # 加密用户密码
  ```


### 查看用户

```bash
all [机器编组] 'id 用户名'        # 看看是否uid一致
all [机器编组] 'ls /home/用户名'  # 看看是否用户目录创建成功
ssh 用户名@jungpu1  # 看看能否正常登陆，使用前面设置的明码
```

### 删除用户

请务必检查用户名，**谨慎操作**，删除不可逆

```bash
all [机器编组] 'userdel -r 用户名'   # 注销账号，并删除/home/用户名、var/mail/test
all [机器编组] 'userdel 用户名'   # 注销账号，不删除/home/用户名、var/mail/test
```

## 编组管理

本包使用`./all_config.sh`文件来配置编组，写法如下

```bash
#!/usr/bin/env bash

# ---------------------- 服务器编组设置------------------
# 顺序编组
# 编组名=(前缀{起始数字..结束数字}后缀)
c=(juncluster{1..4})
g=(jungpu{1..24})
gJ1=(jungpu{1..13})
gJ2=(jungpu{14..24})

# 复合编组
# 编组名=( "${子编组1[@]}" "${子编组2[@]}" "${子编组3[@]}" )
J1=( "${c[@]}" "${gJ1[@]}" )
a=( "${c[@]}" "${g[@]}" )

# 有效编组：即只有写在此处的编组才会被 `all` 命令使用
server_sets=(c  g  gJ1  gJ2  a )
```
