1
无状态组件中含有 build 函数，用于构建一个新的组件。其本质上是使用多种下阶组件封装成一个高阶组件。
有状态组件则没有 build 函数，而是要重写一个 createState 函数，创建 State 对象。State 中含有状态变量，并有一个 build 函数。build 中会依赖 State 的状态，State 中状态改变时框架会让 build 重新执行，类似于 react 的重绘机制。

无状态组件中的变量类似于 react 的 props，有状态组件中的变量类似于 react 的 useState。

2
该如何理解InheritedWidget？
状态类通过继承InheritedWidget将自定义状态注册到框架中。
无状态组件通过调用状态类的静态方法 of，从自己持有的 buildContext 中访问到已经注册到框架中的指定的自定义状态类的自定义状态值。
一旦框架发现注册到框架中的自定义状态发生了改变，就会让依赖了该状态的无状态组件重绘。
自定义状态类可以通过重写updateShouldNotify方法来定义何为“自定义状态发生了改变”。

本质上。state 通过 props 向子组件传递比较麻烦，即使中间的组件用不到相关 state，也需要作为二传手的角色定义 props 来帮忙传递 state。InheritedWidget 使得状态在定义的地方就直接注册到框架中，不需要逐级组件向下传递。下面第 n 级组件想要用这个状态时，只要通过 buildContext 对象找框架要就好了。避免中中间大量的“二传手”的产生。

3
以上两点解决了父组件向子孙组件传递状态的问题，但没有解决子孙组件改变父组件状态的问题。通过在子组件中定义 ValueChanged 函数，子组件在某些事件（被点击）触发时调用 ValueChanged 函数。如此一来，父组件只需要向子组件传递 ValueChanged 函数，在该函数中改变自己（父组件）的状态，就能实现子组件改变父组件状态了。

本质上还是 props 机制，只不过 props 的类型是一个箭头函数（ValueChanged 类型）。
所以也可以通过InheritedWidget的机制跨级传递 ValueChanged？


4
以上三点解决了数据流自上向下传递的问题。但数据流总有一个起点，这个起点是一个有状态组件。也就是说，必须要有一个有状态组件作为高阶组件，其通过传递 props 的方式或InheritedWidget的方式向下传递数据和回调函数。

ChangeNotifier 与 ValueNotifier 则类似于 useState 钩子。旱地拔葱。无需依赖有状态的父组件，而直接将状态定义在框架中。随时改变框架中的状态的值，随时取用框架中的状态。ChangeNotifier中可以封装多个状态及行为，ValueNotifier则是单一的属性，可以直接改变该属性的值或读取该属性的值。
通过为ListenableBuilder组件配置listenable属性，使得其子组件可以使用ChangeNotifier中的状态。
当ChangeNotifier中的状态发生变化时，框架会自动触发ListenableBuilder组件的build函数重新执行，从而使得其子组件重新构建。

5
MVVM 解决的问题是：如何组织应用中的有状态对象。重点是“组织”。
Model 代表业务数据模型，通常是后端提供的数据模型，也就是我常用的“聚合”。
ViewModel 代表的是页面的数据模型，页面的数据可能来自多个 Model，可能还有一些页面自己维护的状态（如 errorMessage），不来自任何 Model。
View 就是呈现的页面视觉，是与用户的交互界面。

分离 Model 和 ViewModel 的职责非常有意义。
我在 antdesign 项目中，默认把 Model 作为了 ViewModel，简化了后管系统的逻辑，实现了低代码化。未来在低代码层面也可以允许用户定义 ViewModel，配置 ViewModel 与 Model 的关系。

如何实现 MVVM 模式呢？
将 ViewModel 定义为 ChangeNotifier。视图组件中使用ListenableBuilder组件来监听 ViewModel 中的状态变化，从而实现视图的更新。

6
为什么还需要 Riverpod？

- 解耦 BuildContext：使用 `ref.read / ref.watch / ref.listen` 获取与订阅状态，业务逻辑可放在纯 Dart 层，更易复用与测试。
- 自动生命周期管理：`autoDispose` 按需创建/销毁，减少手动 `dispose` 的心智负担与泄漏风险。
- 声明式依赖：Provider 可以依赖 Provider（同步/异步/派生），形成可推导依赖图，复杂场景更稳健。
- 异步是一等公民：`FutureProvider` / `StreamProvider` + `AsyncValue` 统一处理“加载/错误/成功”三态，少样板代码。
- 精准重建与性能：基于依赖自动决定重建范围，支持 `select` 等细粒度订阅，避免无关重建。
- 可测试与注入：通过 `ProviderScope(overrides: ...)` 轻松替换依赖，单测/集成测试可控可观测。
- 类型安全与可维护性：配合 `riverpod_generator` 获得编译期校验、强类型 API，重构安全。

最小示例（计数器）：
```dart
// 声明一个状态提供者（无需 BuildContext）
final counterProvider = StateProvider<int>((ref) => 0);

class CounterView extends ConsumerWidget {
  const CounterView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);            // 订阅
    return ElevatedButton(
      onPressed: () => ref.read(counterProvider.notifier).state++, // 更新
      child: Text('count: $count'),
    );
  }
}
```

最小示例（异步三态）：
```dart
final userProvider = FutureProvider<User>((ref) async {
  final api = ref.read(apiProvider);
  return api.fetchUser();
});

class UserView extends ConsumerWidget {
  const UserView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(userProvider);
    return asyncUser.when(
      data: (u) => Text(u.name),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('error: $e'),
    );
  }
}
```

何时考虑使用 Riverpod：
- 跨页面/跨层复用状态多，或希望业务下沉到 service/repository/纯 Dart。
- 依赖关系复杂、异步/缓存/分页场景多，需要更强的组合能力与更少样板。
- 追求测试友好与依赖注入，强调可维护与可观测。

7
为什么用 StateNotifier？

存在的必要性：
- 将业务动作封装为方法（add/toggle/load...），从 UI 抽离，语义清晰、易复用与测试。
- 鼓励不可变更新（state = 新值），避免隐式可变带来的“状态被谁改了”的不确定性。
- 当 `StateProvider` 不再够用（多字段/多动作/复杂规则）而 `ChangeNotifier` 又过于宽松时，`StateNotifier` 恰到好处。

为 Riverpod 补充的能力：
- 更强的结构化：以“模型+动作”组织状态，天然适配 MVVM 中的 ViewModel 职责。
- 更易测试：new 出通知器，调用方法断言 `state` 即可，无需构建 Widget。
- 更精准订阅：配合 `select`/派生 Provider 只重建必要视图。

对比案例：不仅演示用法，更体现收益（以 Todo 为例）

仅用 Riverpod（StateProvider）方案：
```dart
class Todo {
  final String id;
  final String title;
  final bool completed;
  const Todo({required this.id, required this.title, this.completed = false});
  Todo toggle() => Todo(id: id, title: title, completed: !completed);
}

// 分散的 Provider：一个存列表，一个存筛选条件
final todosProvider = StateProvider<List<Todo>>((ref) => const []);
final filterProvider = StateProvider<String>((ref) => 'all'); // all/active/done

// UI 里直接改 list，容易复制更新逻辑到多个地方
void addTodo(WidgetRef ref, String title) {
  final list = ref.read(todosProvider.notifier).state;
  ref.read(todosProvider.notifier).state = [
    ...list,
    Todo(id: DateTime.now().microsecondsSinceEpoch.toString(), title: title),
  ];
}

void toggleTodo(WidgetRef ref, String id) {
  final list = ref.read(todosProvider);
  ref.read(todosProvider.notifier).state =
      list.map((t) => t.id == id ? t.toggle() : t).toList();
}

// 问题：
// - 业务规则（如去重、长度上限、批量操作）散落在多个 UI 入口，难以统一与复用
// - 想加统计/派生数据时，容易在多处重复计算或订阅过粗导致无谓重建
```

Riverpod + StateNotifier 方案（动作内聚、边界清晰）：
```dart
class TodosState {
  final List<Todo> items;
  final String filter; // all/active/done
  const TodosState({required this.items, required this.filter});

  TodosState copyWith({List<Todo>? items, String? filter}) =>
      TodosState(items: items ?? this.items, filter: filter ?? this.filter);
}

class TodosNotifier extends StateNotifier<TodosState> {
  TodosNotifier(): super(const TodosState(items: [], filter: 'all'));

  void add(String title) {
    if (title.trim().isEmpty) return; // 集中校验
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final next = [...state.items, Todo(id: id, title: title)];
    state = state.copyWith(items: next);
  }

  void toggle(String id) {
    final next = state.items.map((t) => t.id == id ? t.toggle() : t).toList();
    state = state.copyWith(items: next);
  }

  void clearCompleted() {
    state = state.copyWith(items: state.items.where((t) => !t.completed).toList());
  }

  void setFilter(String filter) {
    state = state.copyWith(filter: filter);
  }
}

final todosProviderRP =
  StateNotifierProvider<TodosNotifier, TodosState>((ref) => TodosNotifier());

// 派生 Provider：只根据当前 filter 计算可见列表，便于精准订阅
final visibleTodosProvider = Provider<List<Todo>>((ref) {
  final s = ref.watch(todosProviderRP);
  switch (s.filter) {
    case 'active':
      return s.items.where((t) => !t.completed).toList();
    case 'done':
      return s.items.where((t) => t.completed).toList();
    default:
      return s.items;
  }
});

// UI 更薄：只调用动作方法，订阅粒度可控
class TodosView extends ConsumerWidget {
  const TodosView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(visibleTodosProvider); // 精准订阅
    return Column(children: [
      for (final t in todos)
        ListTile(
          title: Text(t.title),
          leading: Checkbox(
            value: t.completed,
            onChanged: (_) => ref.read(todosProviderRP.notifier).toggle(t.id),
          ),
        ),
      Row(children: [
        ElevatedButton(
          onPressed: () => ref.read(todosProviderRP.notifier).clearCompleted(),
          child: const Text('清除已完成'),
        ),
      ]),
    ]);
  }
}
```

收益总结：
- 规则集中：校验、去重、批量、边界都在 `TodosNotifier`，UI 仅触发动作。
- 易扩展：新增统计/分页/缓存等派生逻辑，用派生 Provider 组合即可。
- 可测试：直接 new `TodosNotifier`，调用 `add/toggle/clearCompleted` 断言 `state`。
- 性能友好：`visibleTodosProvider` 控制重建范围，避免列表外组件重建。
