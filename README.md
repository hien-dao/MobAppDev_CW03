# 📝 Task Manager (Flutter + Firebase)

This app is a simple task manager built with Flutter and Firebase, featuring real-time updates, dark mode support, and search filtering.

---

# 🌙 Dark Mode Toggle

The app supports both light and dark themes using Flutter's ThemeMode system.

## How it works

The root widget (`MyApp`) manages the theme state:

ThemeMode _themeMode = ThemeMode.system;

A toggle switch in the AppBar lets the user switch themes:

setState(() {
  _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
});

The MaterialApp applies the theme like this:

MaterialApp(
  themeMode: _themeMode,
  theme: ThemeData(brightness: Brightness.light),
  darkTheme: ThemeData(brightness: Brightness.dark),
);

## Result

- Instant theme switching
- Works across the entire app
- Defaults to system theme

---

# 🔍 Search & Filter

The app includes a real-time search bar that filters tasks by title.

## How it works

A TextEditingController tracks input:

final TextEditingController _searchController = TextEditingController();

The search query is stored in state:

String _searchQuery = '';

On every keystroke:

onChanged: (value) {
  setState(() {
    _searchQuery = value.toLowerCase();
  });
}

Tasks are filtered inside StreamBuilder:

final tasks = allTasks.where((task) {
  return task.title.toLowerCase().contains(_searchQuery);
}).toList();

## Result

- Instant filtering (no Firebase queries)
- Case-insensitive search
- Smooth real-time updates

---

# 🚀 Features

- Create, update, delete tasks
- Toggle task completion
- Nested subtasks
- Real-time Firebase sync
- Dark mode toggle
- Live search filtering

---

# 📦 Tech Stack

- Flutter (Material 3)
- Firebase Firestore
- Dart