#  README

Please open `SkyInterview.xcworkspace` to get started.  It should be compatible with any version of Xcode 11.

## DependenciesContainer project

This project contains a framework target which aims to address the task presented.

#### Basic Usage

```
let dependenciesContainer = DependenciesContainer()

dependenciesContainer.register(ViewController.self) { dc in
    let networking = dc.resolve(Networking.self)
    return ViewController(networking: networking)
}

dependenciesContainer.register(Networking.self) { _ in
    return ConcreteNetworking(baseUrl: "http://sky.com)
}
```

```
let viewController = dependenciesContainer.resolve(ViewController.self)
let networking = dependenciesContainer.resolve(Networking.self)
```

#### Registering multiple Instances of the same type

Use the optional `key` parameter of the `register` and `resolve` functions to work with multiple objects of the same type.

```
let dependenciesContainer = DependenciesContainer()

dependenciesContainer.register(Person.self, key: "Queen Elizabeth") { _ in
    return Person(name: "Queen Elizabeth")
}

dependenciesContainer.register(Person.self, key: "Prince Charles") { _ in
    return Person(name: "Prince Charles")
}
```

```
let charles = dependenciesContainer.resolve(Person.self, key: "Prince Charles")
let elizabeth = dependenciesContainer.resolve(Person.self, key: "Queen Elizabeth")
```

#### Registering circular dependencies

It is possible to `register` objects that have circular depenedencies by using a `postConstruction` closure. 

> A `postConstruction` closure is not invoked until after invocation of the `constructor` closure has returned and therefore avoids any potential race-conditions.

```
let dependenciesContainer = DependenciesContainer()

dependenciesContainer.register(ViewController.self) { dc in
    let dataProvider = dc.resolve(DataProvider.self)
    return ViewController(dataProvider: dataProvider)
}

dependenciesContainer.register(DataProvider.self, constructor: { _ in
    return DataProvider()
}, postConsruction: { dc in
    let dataProvider = de.resolve(DataProvider.self)
    dataProvider.delegate = dc.resolve(ViewController.self)
})
```
>  NOTE: its possible to resolve these dependencies in any order, at the objects will only be instanciated once.
```
let dataProvider = dependenciesContainer.resolve(DataProvider.self)
let viewController = dependenciesContainer.resolve(ViewController.self)
```

#### Unit Tests

The `DependenciesContainerTests` cover all of the scenario's provided above.  100% coverage has been achieved.


## Demo project

I would be grateful if the code in the Demo project weren't significantly critiqued.  

This presents an extremely rushed attempt at demonstrating how one might use a `DependenciesContainer` **in-conjunction** with "Protocol Composition" to achieve dependency injection.  

This aims to address some of the drawbacks with the ServiceLocator Pattern and I thought this might make a good point of discussion for interview. 


## To Do

There are many potential drawbacks to my solution that might be addressed in future...

#### Thread Safety

If more than one thread were to attempt to `register`,  `resolve` or `deregister` dependencies at the same time the current behaviour is undefined.

#### Object Scope & Lifespan

Granular control of object scope/lifespan is not currently possible.   At present, once a dependency has been resolved it remains cached within the `DependenciesContainer`.  It possible to `deregister` a dependency, which will remove it from the cache but one will need to `register` the dependency again.
