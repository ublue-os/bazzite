from collections import namedtuple
import os
from pathlib import Path, PurePath
import shlex
import subprocess


class Git:
    """Use git commands in mdbook preprocessors"""

    def __init__(self, cwd: PurePath | str) -> None:
        self._cwd = Path(cwd)
        self._environ = os.environ.copy()
        self._environ["LC_ALL"] = "C"

    class CommandOutput(namedtuple("CommandOutput", ["stdout", "stderr"])):
        def __str__(self) -> str:
            return self.stdout

    def _git(self, commands: list[str] | str) -> CommandOutput:
        """Run a git command

        Args:
            commands (list[str] | str): commands and args passed to git.

        Returns:
            CommandOutput: Tuple containing `stdout` and `stderr`
        """
        if type(commands) is str:
            commands = shlex.split(commands)
        proc = subprocess.run(
            ["git", *commands],
            capture_output=True,
            text=True,
            env=self._environ,
            cwd=self._cwd,
        )
        return self.CommandOutput(stdout=proc.stdout, stderr=proc.stderr)

    def log(self, *args: str) -> CommandOutput:
        return self._git(["log", *args])
