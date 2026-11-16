# Daylight — Daily Planner

A desktop daily planner built with **C++17** and **Qt Quick / QML**,
featuring a clean interface and local JSON storage.

## Features

- Create, edit, delete, and complete tasks
- Organize tasks by date
- Set optional times, priorities, and notes
- Search task titles and notes
- Filter pending and completed tasks
- Track daily completion progress
- Save changes automatically to a local JSON file
- Validate input and handle storage errors
- Use keyboard shortcuts for common actions

## Built With

- **C++17** — application logic and task management
- **Qt 6** — application framework
- **QML / Qt Quick Controls** — user interface
- **JSON** — local data storage
- **CMake** — build configuration
- **Qt Test** — automated backend tests

## Getting Started

### Requirements

- Qt **6.4 or later** with Qt Quick, Quick Controls 2, and Qt Test
- A C++17-compatible compiler
- CMake **3.21 or later**

Qt 6.8 is recommended.

### Run with Qt Creator

1. Clone this repository.
2. Open `CMakeLists.txt` in Qt Creator.
3. Select a compatible desktop Qt kit.
4. Configure, build, and run the project.

If Qt Test is not installed, configure with `BUILD_TESTING=OFF`
to build only the application.

### Build from the Command Line

Replace the Qt installation path with your desktop kit path:

```sh
cmake -S . -B build -DCMAKE_PREFIX_PATH="/path/to/Qt/6.8.3/gcc_64"
cmake --build build --parallel
ctest --test-dir build --output-on-failure
```

Run on Linux:

```sh
./build/daylight
```

On Windows, the executable may be located at `build/daylight.exe`
or `build/Release/daylight.exe`, depending on the generator.

Qt Creator configures the Qt runtime environment automatically.
Command-line execution requires the matching Qt libraries
and plugins to be available.

### Ubuntu Dependencies

```sh
sudo apt install build-essential cmake ninja-build \
  qt6-base-dev qt6-declarative-dev \
  qml6-module-qtquick qml6-module-qtquick-controls \
  qml6-module-qtquick-layouts qml6-module-qtquick-window \
  qml6-module-qtqml-workerscript qml6-module-qtquick-templates
```

Then build and run:

```sh
cmake -S . -B build -G Ninja
cmake --build build
ctest --test-dir build --output-on-failure
./build/daylight
```

## Project Structure

```text
Daylight/
├── src/
│   ├── main.cpp
│   ├── TaskManager.h
│   └── TaskManager.cpp
├── qml/
│   └── Main.qml
├── tests/
│   └── TaskManagerTest.cpp
├── docs/
├── .github/workflows/
├── CMakeLists.txt
└── README.md
```

## Architecture

The project separates task management from presentation:

- `Task` stores the information for a single task.
- `TaskManager` owns a `std::vector<Task>`, validates input,
  filters tasks, and handles JSON storage.
- `Main.qml` defines the interface and user interactions.
- Qt properties, signals, and invokable methods connect C++ to QML.

The interface receives a `QVariantList` snapshot of the visible tasks.
This keeps the implementation approachable. A custom
`QAbstractListModel` would be a useful improvement for larger datasets.

## Task Ordering

Tasks are sorted by:

1. Pending tasks before completed tasks
2. Scheduled tasks before unscheduled tasks
3. Time in ascending order
4. Higher priority when times are equal

Daily progress includes every task on the selected date,
independently of the active search or filter.

Editing a task to another date moves it off the current day's list.

## Data Storage

Tasks are stored in `tasks.json` inside
`QStandardPaths::AppDataLocation`.

Typical locations:

- Linux: `~/.local/share/Daylight/Daylight/tasks.json`
- Windows: `%APPDATA%/Daylight/Daylight/tasks.json`
- macOS: `~/Library/Application Support/Daylight/Daylight/tasks.json`

The exact path is included in storage error messages.

Changes are saved using `QSaveFile` so the existing file is replaced
only after a successful write. Failed saves roll back the in-memory
change.

Invalid data files are preserved and writes are blocked.
To recover, close the application, back up the file, repair or
rename it, and restart. Renaming the file starts a fresh task list.

Data is stored as plain text and is **not encrypted**.
Running multiple instances against the same data file is not supported.

No sample tasks are inserted into real user data.

## Keyboard Shortcuts

| Shortcut | Action |
| --- | --- |
| `Ctrl + N` | Create a new task |
| `Ctrl + F` | Focus the search field |
| `Esc` | Close the task editor |

## Testing

Backend tests cover:

- Task creation, editing, completion, and deletion
- Persistence across restarts
- Input validation
- Search, filtering, sorting, and date navigation
- Invalid-file protection
- Rollback after storage failures

Run the tests with:

```sh
ctest --test-dir build --output-on-failure
```

## Current Scope

The interface is in English and uses Gregorian dates and
24-hour times. The initial date follows the computer's local date.

Task times are used for planning and sorting.
They do not trigger notifications.

Recurring tasks, cloud synchronization, and calendar integrations
are not included.

The project has been built and tested on Linux.
Windows and macOS require additional testing before distributing
binaries.

## Future Improvements

- Task categories and tags
- Monthly calendar view
- Recurring tasks
- Desktop reminders
- SQLite storage
- Additional languages and calendar formats

## License

A project license has not been selected yet.
Add a suitable license before publishing the project as open source.

Qt is distributed under its own license terms.
Review the relevant requirements before distributing Qt libraries
with application binaries.