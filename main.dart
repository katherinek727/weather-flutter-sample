class WeatherPage extends StatefulWidget {
  final WeatherApiService api;

  const WeatherPage({super.key, required this.api});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  WeatherState state = const WeatherState();
  final TextEditingController controller = TextEditingController();

  int _requestId = 0; // prevents race conditions

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> fetch() async {
    final city = controller.text.trim();

    if (city.isEmpty) {
      setState(() {
        state = state.copyWith(
          status: WeatherStatus.error,
          error: 'Please enter a city name',
          data: null,
        );
      });
      return;
    }

    // Close keyboard (more robust)
    FocusManager.instance.primaryFocus?.unfocus();

    final currentRequest = ++_requestId;

    setState(() {
      state = state.copyWith(
        status: WeatherStatus.loading,
        error: null,
      );
    });

    try {
      final result = await widget.api.fetchWeather(city);

      if (!mounted || currentRequest != _requestId) return;

      setState(() {
        state = state.copyWith(
          status: WeatherStatus.success,
          data: result,
          error: null,
        );
      });
    } catch (e) {
      if (!mounted || currentRequest != _requestId) return;

      final message =
          e is WeatherException ? e.message : 'Something went wrong';

      setState(() {
        state = state.copyWith(
          status: WeatherStatus.error,
          error: message,
          data: null, // clear stale data
        );
      });
    }
  }

  String formatTemperature(double temp) =>
      '${temp.toStringAsFixed(1)}°C';

  Widget _buildLoading() => const CircularProgressIndicator();

  Widget _buildError() => Text(
        state.error ?? 'Unknown error',
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget _buildSuccess(Weather weather) {
    final emoji = WeatherUiMapper.emoji(weather.condition);

    return Column(
      children: [
        Semantics(
          label: weather.condition,
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 48),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          formatTemperature(weather.temperature),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(weather.condition.capitalizeWords()),
      ],
    );
  }

  Widget _buildContent() {
    switch (state.status) {
      case WeatherStatus.loading:
        return _buildLoading();
      case WeatherStatus.error:
        return _buildError();
      case WeatherStatus.success:
        final weather = state.data;
        if (weather == null) {
          return const Text('No data available');
        }
        return _buildSuccess(weather);
      case WeatherStatus.idle:
      default:
        return const Text('Search for a city to begin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final weather = state.data;

    return Scaffold(
      backgroundColor: weather != null
          ? WeatherUiMapper.background(weather.condition)
          : Colors.white,
      appBar: AppBar(title: const Text('Weather App')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Enter city',
                hintText: 'e.g., London',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => fetch(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    state.status == WeatherStatus.loading ? null : fetch,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: state.status == WeatherStatus.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Get Weather'),
              ),
            ),
            const SizedBox(height: 20),
            _buildContent(),
          ],
        ),
      ),
    );
  }
}