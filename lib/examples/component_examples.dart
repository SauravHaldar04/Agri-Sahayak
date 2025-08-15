/// Examples of how Gemini should respond with JSON for different component types
class ComponentExamples {
  /// Weather Card Example
  static const String weatherExample = '''
{
  "componentType": "weatherCard",
  "componentData": {
    "location": "Amravati, Maharashtra",
    "temperature": "28",
    "humidity": "65",
    "rainProbability": "30",
    "condition": "Partly Cloudy"
  },
  "text": "Current weather in Amravati is 28°C with 65% humidity and 30% chance of rain.",
  "markdown": "**Current Weather in Amravati**\n\n🌤️ **Partly Cloudy**\n🌡️ **Temperature:** 28°C\n💧 **Humidity:** 65%\n🌧️ **Rain Probability:** 30%"
}
''';

  /// Crop Report Card Example
  static const String cropReportExample = '''
{
  "componentType": "cropReportCard",
  "componentData": {
    "cropName": "Wheat",
    "growthStage": "Flowering",
    "health": "Good",
    "recommendations": "Ensure adequate irrigation and monitor for pest infestation. Apply recommended fertilizers if not done recently."
  },
  "text": "Your wheat crop is in the flowering stage with good health. Ensure adequate irrigation and monitor for pests.",
  "markdown": "**Wheat Crop Report**\n\n🌱 **Growth Stage:** Flowering\n✅ **Health Status:** Good\n💡 **Recommendations:** Ensure adequate irrigation and monitor for pest infestation. Apply recommended fertilizers if not done recently."
}
''';

  /// Time Series Chart Card Example
  static const String timeSeriesExample = '''
{
  "componentType": "timeSeriesChartCard",
  "componentData": {
    "title": "Soybean Price Trend (Last 15 Days)",
    "metric": "Market Price per Quintal",
    "data": [
      {"date": "2024-01-01", "price": 4200},
      {"date": "2024-01-02", "price": 4250},
      {"date": "2024-01-03", "price": 4180}
    ]
  },
  "text": "Soybean prices have shown a slight upward trend over the last 15 days, with current price at ₹4,180 per quintal.",
  "markdown": "**Soybean Price Trend Analysis**\n\n📈 **Last 15 Days Performance**\n💰 **Current Price:** ₹4,180 per quintal\n📊 **Trend:** Slight upward movement\n\n*Data shows daily market prices for soybean in your region*"
}
''';

  /// Soil Analysis Card Example
  static const String soilAnalysisExample = '''
{
  "componentType": "soilAnalysisCard",
  "componentData": {
    "nitrogen": "Medium",
    "phosphorus": "Low",
    "potassium": "High",
    "ph": "6.2",
    "organicMatter": "1.8%"
  },
  "text": "Your soil analysis shows medium nitrogen, low phosphorus, high potassium, and pH of 6.2. Consider adding phosphorus-rich fertilizers.",
  "markdown": "**Soil Health Analysis**\n\n🌱 **Nitrogen (N):** Medium\n🌱 **Phosphorus (P):** Low ⚠️\n🌱 **Potassium (K):** High ✅\n🌱 **pH Level:** 6.2 (Optimal)\n🌱 **Organic Matter:** 1.8%\n\n💡 **Recommendation:** Consider adding phosphorus-rich fertilizers to improve soil fertility."
}
''';

  /// Step-by-Step Guide Example
  static const String stepByStepExample = '''
{
  "componentType": "stepByStepGuideCard",
  "componentData": {
    "title": "How to Apply for Seed Subsidy",
    "steps": [
      "Visit your nearest Krishi Vigyan Kendra (KVK)",
      "Submit your land ownership documents",
      "Fill out the subsidy application form",
      "Attach required documents (Aadhaar, land records)",
      "Submit to the agriculture officer",
      "Wait for verification and approval (7-10 days)",
      "Receive subsidy voucher or direct credit"
    ]
  },
  "text": "Here's a step-by-step guide to apply for seed subsidy through your local KVK.",
  "markdown": "**Seed Subsidy Application Guide**\n\nFollow these steps to apply for seed subsidy:\n\n1. Visit your nearest Krishi Vigyan Kendra (KVK)\n2. Submit your land ownership documents\n3. Fill out the subsidy application form\n4. Attach required documents (Aadhaar, land records)\n5. Submit to the agriculture officer\n6. Wait for verification and approval (7-10 days)\n7. Receive subsidy voucher or direct credit"
}
''';

  /// Interactive Checklist Example
  static const String checklistExample = '''
{
  "componentType": "interactiveChecklistCard",
  "componentData": {
    "title": "Land Preparation Checklist",
    "tasks": [
      "Clear existing vegetation and debris",
      "Test soil pH and nutrient levels",
      "Apply organic matter or compost",
      "Plow the land to proper depth",
      "Level the field for uniform irrigation",
      "Install drainage system if needed",
      "Mark rows for planting"
    ]
  },
  "text": "Use this checklist to ensure proper land preparation before planting your crops.",
  "markdown": "**Land Preparation Checklist**\n\n✅ **Pre-Planting Tasks:**\n\n- Clear existing vegetation and debris\n- Test soil pH and nutrient levels\n- Apply organic matter or compost\n- Plow the land to proper depth\n- Level the field for uniform irrigation\n- Install drainage system if needed\n- Mark rows for planting\n\n*Check off each task as you complete it*"
}
''';

  /// Contact Advisor Example
  static const String contactAdvisorExample = '''
{
  "componentType": "contactAdvisorCard",
  "componentData": {
    "expertName": "Dr. Rajesh Kumar",
    "contact": "+91-98765-43210",
    "specialization": "Soil Health & Crop Nutrition",
    "location": "KVK Amravati"
  },
  "text": "For expert advice on soil health and crop nutrition, contact Dr. Rajesh Kumar at KVK Amravati.",
  "markdown": "**Contact Agricultural Expert**\n\n👨‍🌾 **Expert:** Dr. Rajesh Kumar\n📱 **Contact:** +91-98765-43210\n🎯 **Specialization:** Soil Health & Crop Nutrition\n📍 **Location:** KVK Amravati\n\n💬 **Get personalized advice for your farming challenges**"
}
''';

  /// General Response Example (No specific component)
  static const String generalExample = '''
{
  "componentType": "none",
  "componentData": null,
  "text": "Crop rotation is an excellent practice for maintaining soil health and preventing pest buildup.",
  "markdown": "**Crop Rotation Benefits**\n\n🌱 **Soil Health:** Improves soil structure and fertility\n🐛 **Pest Control:** Breaks pest and disease cycles\n💧 **Nutrient Management:** Different crops use different nutrients\n🌿 **Weed Suppression:** Reduces weed pressure\n\n💡 **Best Practices:**\n- Rotate between different plant families\n- Include legumes to fix nitrogen\n- Plan 3-4 year rotation cycles"
}
''';
}
