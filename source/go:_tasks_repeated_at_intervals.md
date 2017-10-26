title: "Go: tasks repeated at intervals"
date: 2017-10-26 05:35:01 +0000
update: 2017-10-26 05:35:01 +0000
author: codeworm96
# NOTE: the image locate in `source` folder
# cover: "-/images/posts/example.png"
tags:
    - golang
preview: "Use go to run tasks at intervals."

---

Suppose we would like to perform a task repeatedly at regular intervals with a goroutine.

Here is the first try:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	go func() {
		for {
			fmt.Println("hello, world!")
			time.Sleep(5 * time.Second)
		}
	}()
}
```

Oops, it does not work. The main function terminates immediately after starting the goroutine,
and the program terminates with the termination of the main function.

We should let the main function wait for the goroutine. Therefore,
[WaitGroup](https://golang.org/pkg/sync/#WaitGroup) is needed.

```go
package main

import (
	"fmt"
	"sync"
	"time"
)

type WaitGroupWrapper struct {
	wg sync.WaitGroup
}

func (w *WaitGroupWrapper) Spawn(f func()) {
	w.wg.Add(1)
	go func() {
		f()
		w.wg.Done()
	}()
}

func (w *WaitGroupWrapper) Wait() {
	w.wg.Wait()
}

func main() {
	var wg WaitGroupWrapper
	wg.Spawn(func() {
		for {
			fmt.Println("hello, world!")
			time.Sleep(5 * time.Second)
		}
	})
	wg.Wait()
}
```

Note that I used a wrapper to wrap the WaitGroup to make it easier to use.
Now the program works, but we can improve it with tickers, which provide by
Go for doing something repeatedly at regular intervals.

```go
ticker := time.NewTicker(5 * time.Second)
wg.Spawn(func() {
    for {
        <-ticker.C
        fmt.Println("hello, world!")
    }
})
```

Currently, our goroutine runs forever. We can stop it using another channel.

```go
func main() {
	var wg WaitGroupWrapper
	done := make(chan struct{})
	ticker := time.NewTicker(5 * time.Second)
	wg.Spawn(func() {
		for {
			select {
			case <-ticker.C:
				fmt.Println("hello, world!")
			case <-done:
				goto exit
			}
		}
	exit:
	})
	time.Sleep(16 * time.Second)
	close(done)
	wg.Wait()
}
```

## Update

## Reference

## License

- This article is licensed under [CC BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/).
- Please contact <marketing@dongyue.io> for commerical use.
