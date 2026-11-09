import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dashink/core/sound/sound_manager.dart';
import 'package:dashink/data/model/player/player_progress.dart';
import 'package:dashink/data/model/task/task_list.dart';
import 'package:dashink/domain/player/player_repository.dart';
import 'package:dashink/domain/task/task_repository.dart';
import 'package:dashink/presentation/tasks/bloc/tasks_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockTaskRepository extends Mock implements TaskRepository {}

class _MockPlayerRepository extends Mock implements PlayerRepository {}

class _MockSoundManager extends Mock implements SoundManager {}

void main() {
  const claimable = GameTask(
    id: 'ach_games_10',
    target: 10,
    progress: 10,
    reward: 50,
    status: TaskStatus.claimable,
  );
  const list = TaskList(
    period: TaskPeriod.daily,
    tasks: [claimable],
  );

  late _MockTaskRepository tasks;
  late _MockPlayerRepository player;
  late _MockSoundManager sound;

  setUpAll(() {
    registerFallbackValue(TaskPeriod.daily);
    registerFallbackValue(claimable);
    registerFallbackValue(GameSound.coin);
    registerFallbackValue(list);
  });

  setUp(() {
    tasks = _MockTaskRepository();
    player = _MockPlayerRepository();
    sound = _MockSoundManager();
    when(() => player.progress).thenReturn(const PlayerProgress());
    when(() => player.changes).thenAnswer((_) => const Stream.empty());
    when(() => tasks.cached(any())).thenReturn(null);
    when(() => tasks.fetch(any())).thenAnswer((_) async => list);
    when(() => tasks.saveCache(any())).thenAnswer((_) async {});
  });

  TasksBloc build() => TasksBloc(tasks, player, sound);

  group('TasksBloc claim', () {
    blocTest<TasksBloc, TasksState>(
      'görev sunucu cevabından ÖNCE alındı olur ve kutlama durumu yayılır',
      build: build,
      act: (bloc) async {
        final pending = Completer<GameTask>();
        when(() => tasks.claim(any())).thenAnswer((_) => pending.future);
        bloc.add(const TasksPeriodSelected(TaskPeriod.daily));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const TasksClaimRequested(claimable));
        await Future<void>.delayed(Duration.zero);
        // Sunucu henüz cevap vermedi; durum zaten "claimed".
        final s = bloc.state;
        expect(s, isA<TasksClaimSuccess>());
        expect(
          (s as TasksLoaded).list.tasks.single.status,
          TaskStatus.claimed,
        );
        pending.complete(claimable.copyWith(status: TaskStatus.claimed));
      },
      skip: 2,
      expect: () => [
        isA<TasksClaimSuccess>(),
        isA<TasksLoaded>().having(
          (s) => s.list.tasks.single.status,
          'status',
          TaskStatus.claimed,
        ),
      ],
      verify: (_) => verify(() => sound.play(GameSound.coin)).called(1),
    );

    blocTest<TasksBloc, TasksState>(
      'sunucu hata verirse görev yeniden "al" durumuna döner',
      build: build,
      act: (bloc) async {
        when(() => tasks.claim(any())).thenThrow(Exception('offline'));
        bloc.add(const TasksPeriodSelected(TaskPeriod.daily));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const TasksClaimRequested(claimable));
      },
      skip: 2,
      expect: () => [
        isA<TasksClaimSuccess>(),
        isA<TasksClaimFailure>().having(
          (s) => s.list.tasks.single.status,
          'status',
          TaskStatus.claimable,
        ),
      ],
    );

    blocTest<TasksBloc, TasksState>(
      'çift dokunuş tek istek gönderir',
      build: build,
      act: (bloc) async {
        when(
          () => tasks.claim(any()),
        ).thenAnswer(
          (_) async => claimable.copyWith(status: TaskStatus.claimed),
        );
        bloc.add(const TasksPeriodSelected(TaskPeriod.daily));
        await Future<void>.delayed(Duration.zero);
        bloc
          ..add(const TasksClaimRequested(claimable))
          ..add(const TasksClaimRequested(claimable));
      },
      verify: (_) => verify(() => tasks.claim(any())).called(1),
    );
  });
}
