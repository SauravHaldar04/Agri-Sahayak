# Agri Sahayak - Dynamic UI Components Documentation

## Overview

Agri Sahayak is a Flutter application that integrates with Gemini AI to provide dynamic, AI-powered responses through various UI components. The system expects Gemini to return structured JSON responses that specify which component type to display and the required data.

## JSON Response Format

Gemini should return responses in the following JSON format:

```json
{
  "componentType": "component_name",
  "componentData": {
    // specific data for the component
  },
  "text": "Human readable response text",
  "markdown": "Markdown formatted response"
}
```

## Available Component Types

### 1. Weather Card (`weatherCard`)

**Use Case**: Weather queries, current conditions, forecasts

**Required Fields**:
```json
{
  "componentType": "weatherCard",
  "componentData": {
    "temperature": 28,
    "description": "Partly Cloudy",
    "highTemp": 32,
    "lowTemp": 22,
    "humidity": 65,
    "rainProbability": 20,
    "condition": "partly_cloudy",
    "forecast": [
      {
        "date": "2024-01-15",
        "condition": "sunny",
        "highTemp": 30,
        "lowTemp": 20
      }
    ]
  },
  "text": "Current weather is 28°C, partly cloudy with 20% chance of rain.",
  "markdown": "**Current Weather**: 28°C, Partly Cloudy\n\n**Forecast**: High 32°C, Low 22°C\n**Humidity**: 65%\n**Rain Chance**: 20%"
}
```

**Field Descriptions**:
- `temperature`: Current temperature in Celsius
- `description`: Human-readable weather description
- `highTemp`/`lowTemp`: High and low temperatures for the day
- `humidity`: Humidity percentage
- `rainProbability`: Chance of rain percentage
- `condition`: Weather condition (sunny, cloudy, rainy, partly_cloudy, stormy, thunderstorm)
- `forecast`: Array of 5-day forecast data (optional)

### 2. Soil Analysis Card (`soilAnalysisCard`)

**Use Case**: Soil health reports, nutrient analysis, soil testing results

**Required Fields**:
```json
{
  "componentType": "soilAnalysisCard",
  "componentData": {
    "location": "Amravati District",
    "nitrogen": "Medium",
    "phosphorus": "Low",
    "potassium": "High",
    "ph": "6.8",
    "organicCarbon": "1.2"
  },
  "text": "Your soil analysis shows medium nitrogen, low phosphorus, and high potassium levels.",
  "markdown": "**Soil Health Summary** - Amravati District\n\n**Nitrogen**: Medium\n**Phosphorus**: Low\n**Potassium**: High\n**pH Level**: 6.8\n**Organic Carbon**: 1.2%"
}
```

**Field Descriptions**:
- `location`: Geographic location or farm name
- `nitrogen`/`phosphorus`/`potassium`: Nutrient levels (Deficient, Low, Medium, High, Optimal, Surplus)
- `ph`: Soil pH value
- `organicCarbon`: Organic carbon percentage

### 3. Crop Report Card (`cropReportCard`)

**Use Case**: Crop status reports, growth monitoring, health assessments

**Required Fields**:
```json
{
  "componentType": "cropReportCard",
  "componentData": {
    "cropName": "Wheat",
    "location": "Your Farm",
    "growthStage": "Tillering",
    "health": "Good",
    "pestRisk": "Low Risk",
    "marketTrend": "Stable",
    "nextAction": "Top Dressing (in ~3 days)",
    "recommendations": "Apply nitrogen fertilizer and ensure proper irrigation."
  },
  "text": "Your wheat crop is in the tillering stage with good health and low pest risk.",
  "markdown": "**Wheat Crop Report**\n\n**Growth Stage**: Tillering\n**Health Status**: Good\n**Pest Alert**: Low Risk\n**Market Trend**: Stable\n\n**Next Action**: Top Dressing (in ~3 days)"
}
```

**Field Descriptions**:
- `cropName`: Name of the crop
- `location`: Farm or field location
- `growthStage`: Current growth phase (Germination, Tillering, Flowering, etc.)
- `health`: Overall crop health (Poor, Fair, Good, Excellent)
- `pestRisk`: Pest threat level (Low Risk, Medium Risk, High Risk)
- `marketTrend`: Market price trend (Declining, Stable, Rising)
- `nextAction`: Recommended next action with timeline
- `recommendations`: Additional advice or instructions

### 4. Visual Diagnosis Card (`visualDiagnosisCard`)

**Use Case**: Plant disease identification, pest problems, visual analysis

**Required Fields**:
```json
{
  "componentType": "visualDiagnosisCard",
  "componentData": {
    "issue": "Late Blight Fungus",
    "severity": "high",
    "confidence": 0.92,
    "solution": "Apply fungicide and improve air circulation around plants.",
    "symptoms": ["Brown spots on leaves", "White fungal growth", "Leaf wilting"],
    "prevention": "Avoid overhead watering and maintain plant spacing."
  },
  "text": "Your plants show symptoms of Late Blight Fungus with 92% confidence.",
  "markdown": "**Diagnosis**: Late Blight Fungus\n\n**Confidence**: 92%\n**Severity**: High\n\n**Treatment**: Apply fungicide and improve air circulation."
}
```

**Field Descriptions**:
- `issue`: Identified problem or disease name
- `severity`: Problem severity (low, medium, high, critical)
- `confidence`: AI confidence score (0.0 to 1.0)
- `solution`: Treatment or solution steps
- `symptoms`: List of observed symptoms
- `prevention`: Preventive measures for future

### 5. Policy Explanation Card (`policyCard`)

**Use Case**: Government schemes, subsidies, agricultural policies

**Required Fields**:
```json
{
  "componentType": "policyCard",
  "componentData": {
    "scheme": "PM-KISAN",
    "ministry": "Ministry of Agriculture",
    "benefits": ["₹6,000 per year", "Direct bank transfer", "No middlemen"],
    "eligibility": ["Small and marginal farmers", "Landholding up to 2 hectares"],
    "documents": ["Aadhaar card", "Land records", "Bank account details"],
    "amount": "6,000",
    "deadline": "31st March 2024",
    "contact": "1800-180-1551"
  },
  "text": "PM-KISAN provides ₹6,000 annually to eligible farmers through direct bank transfer.",
  "markdown": "**PM-KISAN Scheme**\n\n**Benefits**:\n• ₹6,000 per year\n• Direct bank transfer\n• No middlemen\n\n**Eligibility**: Small and marginal farmers"
}
```

**Field Descriptions**:
- `scheme`: Name of the government scheme
- `ministry`: Responsible ministry or department
- `benefits`: List of scheme benefits
- `eligibility`: Eligibility criteria
- `documents`: Required documents
- `amount`: Financial amount or benefit value
- `deadline`: Application deadline (optional)
- `contact`: Contact information (optional)

### 6. Contact Advisor Card (`contactAdvisorCard`)

**Use Case**: Expert consultation, advisor contact information

**Required Fields**:
```json
{
  "componentType": "contactAdvisorCard",
  "componentData": {
    "expertName": "Dr. Rajesh Kumar",
    "contact": "+91 98765 43210",
    "specialization": "Soil Science",
    "institution": "KVK Amravati",
    "availability": "Mon-Fri, 9 AM - 5 PM",
    "email": "rajesh.kumar@kvk.gov.in"
  },
  "text": "Contact Dr. Rajesh Kumar, Soil Science expert at KVK Amravati for personalized advice.",
  "markdown": "**Agricultural Expert**\n\n**Dr. Rajesh Kumar**\n**Specialization**: Soil Science\n**Contact**: +91 98765 43210"
}
```

**Field Descriptions**:
- `expertName`: Name of the advisor or expert
- `contact`: Phone number
- `specialization`: Area of expertise
- `institution`: Institution or organization
- `availability`: Working hours or availability
- `email`: Email address (optional)

### 7. Time Series Chart Card (`timeSeriesChartCard`)

**Use Case**: Market trends, price history, data over time

**Required Fields**:
```json
{
  "componentType": "timeSeriesChartCard",
  "componentData": {
    "title": "Market Price Trends",
    "metric": "Soybean prices over 30 days",
    "data": [
      {"date": "2024-01-01", "value": 4500},
      {"date": "2024-01-02", "value": 4550},
      {"date": "2024-01-03", "value": 4600}
    ],
    "unit": "₹/quintal",
    "trend": "rising",
    "change": "+5.2%"
  },
  "text": "Soybean prices have increased by 5.2% over the last 30 days.",
  "markdown": "**Market Price Trends**\n\nSoybean prices over 30 days\n**Current**: ₹4,600/quintal\n**Change**: +5.2%"
}
```

**Field Descriptions**:
- `title`: Chart title
- `metric`: What the chart measures
- `data`: Array of date-value pairs
- `unit`: Unit of measurement
- `trend`: Overall trend (rising, falling, stable)
- `change`: Percentage or absolute change

### 8. Comparison Table Card (`comparisonTableCard`)

**Use Case**: Product comparisons, variety analysis, feature comparison

**Required Fields**:
```json
{
  "componentType": "comparisonTableCard",
  "componentData": {
    "title": "Seed Varieties Comparison",
    "items": "Drought-resistant maize varieties",
    "comparisonData": [
      {
        "name": "Hybrid 123",
        "yield": "8-10 tons/ha",
        "droughtTolerance": "High",
        "maturity": "110 days",
        "price": "₹2,500/kg"
      },
      {
        "name": "Variety 456",
        "yield": "6-8 tons/ha",
        "droughtTolerance": "Medium",
        "maturity": "100 days",
        "price": "₹1,800/kg"
      }
    ],
    "recommendation": "Hybrid 123 for high drought tolerance and yield"
  },
  "text": "Comparing drought-resistant maize varieties: Hybrid 123 offers high drought tolerance and yield.",
  "markdown": "**Seed Varieties Comparison**\n\nComparing drought-resistant maize varieties with yield, tolerance, and pricing information."
}
```

**Field Descriptions**:
- `title`: Comparison title
- `items`: What is being compared
- `comparisonData`: Array of items with their properties
- `recommendation`: Suggested choice or conclusion

### 9. Step-by-Step Guide Card (`stepByStepGuideCard`)

**Use Case**: Process instructions, how-to guides, sequential tasks

**Required Fields**:
```json
{
  "componentType": "stepByStepGuideCard",
  "componentData": {
    "title": "Soil Sampling Process",
    "description": "Proper soil sampling techniques for accurate laboratory analysis",
    "steps": [
      "Choose representative locations in your field",
      "Use a soil auger to collect samples from 0-15 cm depth",
      "Mix samples thoroughly in a clean container",
      "Send to laboratory for analysis",
      "Follow recommendations based on results"
    ],
    "estimatedTime": "2-3 hours",
    "materials": ["Soil auger", "Clean containers", "Labels"],
    "tips": "Avoid sampling near field edges or areas with different soil types"
  },
  "text": "Follow these 5 steps for proper soil sampling: choose locations, collect samples, mix thoroughly, send to lab, and follow recommendations.",
  "markdown": "**Soil Sampling Process**\n\nA step-by-step guide to collect soil samples for analysis."
}
```

**Field Descriptions**:
- `title`: Guide title
- `description`: Brief description of the process (optional)
- `steps`: Array of sequential steps
- `estimatedTime`: Time required to complete
- `materials`: Required materials or tools
- `tips`: Additional helpful advice

### 10. Interactive Checklist Card (`interactiveChecklistCard`)

**Use Case**: Task tracking, progress monitoring, activity checklists

**Required Fields**:
```json
{
  "componentType": "interactiveChecklistCard",
  "componentData": {
    "title": "Land Preparation Checklist",
    "tasks": [
      "Clear existing vegetation",
      "Plow the soil to 20-25 cm depth",
      "Level the field properly",
      "Apply organic manure",
      "Prepare seedbeds if needed"
    ],
    "progress": 0.6,
    "completedTasks": [0, 1, 2],
    "estimatedCompletion": "2 days",
    "priority": "High"
  },
  "text": "Land preparation checklist: 3 out of 5 tasks completed. Estimated completion in 2 days.",
  "markdown": "**Land Preparation Checklist**\n\nTrack your progress through essential land preparation tasks."
}
```

**Field Descriptions**:
- `title`: Checklist title
- `tasks`: Array of tasks to complete
- `progress`: Completion percentage (0.0 to 1.0)
- `completedTasks`: Indices of completed tasks
- `estimatedCompletion`: Time to complete remaining tasks
- `priority`: Priority level (Low, Medium, High, Critical)

### 11. PDF Preview Card (`pdfPreviewCard`)

**Use Case**: Document sharing, guidelines, reports with voice overview

**Required Fields**:
```json
{
  "componentType": "pdfPreviewCard",
  "componentData": {
    "title": "Organic Farming Guidelines 2024",
    "description": "Comprehensive guide for organic farming practices and certification requirements",
    "pdfUrl": "https://example.com/organic-farming-guidelines-2024.pdf",
    "voiceOverview": "This document provides detailed guidelines for organic farming practices including soil management, pest control, and certification requirements. It covers sustainable agriculture methods and compliance standards for organic certification.",
    "fileSize": "2.4 MB",
    "pages": "45",
    "category": "Guidelines"
  },
  "text": "Here's the latest organic farming guidelines document with voice overview.",
  "markdown": "**Organic Farming Guidelines 2024**\n\n📄 **Document:** 45 pages, 2.4 MB\n🎤 **Voice Overview:** Available\n📋 **Category:** Guidelines\n\n*Click to view the full PDF with voice narration*"
}
```

**Field Descriptions**:
- `title`: Document title
- `description`: Brief description of the document
- `pdfUrl`: URL to the PDF file
- `voiceOverview`: Text that will be read aloud as voice overview (optional)
- `fileSize`: Size of the PDF file
- `pages`: Number of pages in the document
- `category`: Document category or type

## Fallback Response

When no specific component type is applicable, use:

```json
{
  "componentType": "none",
  "componentData": null,
  "text": "Your response text here",
  "markdown": "**Markdown formatted** response with any formatting you want"
}
```

## Implementation Notes

1. **Component Type Mapping**: The system automatically maps component type strings to the corresponding enum values
2. **Data Validation**: All component data fields are optional and have sensible defaults
3. **Responsive Design**: All components are designed to work on both mobile and desktop screens
4. **Error Handling**: If JSON parsing fails, the system falls back to displaying the response as markdown
5. **Accessibility**: Components include proper text alternatives and touch-friendly interactions

## Example Gemini Prompt

```
You are an agricultural expert. Analyze the following question and respond with a JSON object that specifies the component type and required data. Use this format:

{
  "componentType": "component_name",
  "componentData": {
    // specific data for the component
  },
  "text": "Human readable response text",
  "markdown": "Markdown formatted response"
}

Available component types:
- weatherCard: for weather queries
- cropReportCard: for crop status/reports
- timeSeriesChartCard: for trend data
- comparisonTableCard: for comparisons
- soilAnalysisCard: for soil health
- visualDiagnosisCard: for plant problems
- stepByStepGuideCard: for processes
- interactiveChecklistCard: for task lists
- policyCard: for government schemes
- contactAdvisorCard: for expert contact
- pdfPreviewCard: for documents with voice overview
- none: for general responses

Question: [USER_QUESTION]
```

## Testing Components

Use the Component Preview Screen to test all components with dummy data:

```bash
flutter run -t lib/main_preview.dart
```

This will launch a dedicated preview interface where you can see how each component renders with sample data.
