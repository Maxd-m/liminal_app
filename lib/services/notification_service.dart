import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Inicializar zonas horarias
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // Método para programar la notificación
  Future<void> scheduleObjectiveNotification({
    required int id,
    required String title,
    required String body,
    required DateTime deadline,
  }) async {
    // print(deadline.day);
    // Fecha: 2 días antes a las 9 AM
    DateTime scheduledDate = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
      0,
      1,
    ).subtract(const Duration(days: 2));

    print(scheduledDate);

    // --- LÓGICA DE PRUEBA: 15 SEGUNDOS EN EL FUTURO ---
    // DateTime scheduledDate = DateTime.now().add(const Duration(seconds: 15));

    // Validar que no esté en el pasado
    if (scheduledDate.isBefore(DateTime.now())) {
      print('La fecha de notificación ya pasó, no se programará.');
      return;
    }

    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'objective_channel_id',
          'Recordatorios de Objetivos',
          channelDescription:
              'Canal para avisos 2 días antes de la fecha límite',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),

      // ✅ Parámetros correctos actuales
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null, // opcional pero recomendado
    );
    // Imprimir en consola para confirmar que el código pasó por aquí
    print(' Notificación programada para: $scheduledDate');
  }

  // Cancelar notificación
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> checkPendingNotifications() async {
    final pendingRequests = await _flutterLocalNotificationsPlugin
        .pendingNotificationRequests();
    print('🔔 Tienes ${pendingRequests.length} notificaciones pendientes:');
    for (var request in pendingRequests) {
      print('- ID: ${request.id}, Título: ${request.title}');
    }
  }
}
