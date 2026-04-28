let chartInstance = null;

function RenderChart(dataset1Name, dataset2Name, labels, data1, data2) {
    const ctx = document.getElementById('myChart');
    
    if (chartInstance != null) {
        chartInstance.destroy(); 
    }

    chartInstance = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [
                {
                    label: dataset1Name,
                    data: data1,
                    backgroundColor: '#1f77b4'
                },
                {
                    label: dataset2Name,
                    data: data2,
                    backgroundColor: '#ff7f0e'
                }
            ]
        },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: true,
                    position: 'bottom',
                    labels: {
                        boxWidth: 10,
                        boxHeight: 10,
                        borderRadius: 2,
                        useBorderRadius: true,
                        font: { size: 11 },
                        padding: 10
                    }
                }
            },
            scales: {
                x: {
                    grid: { display: false },
                    ticks: { font: { size: 10 } }
                },
                y: {
                    grid: { color: '#f0f0f0' },
                    ticks: {
                        font: { size: 10 },
                        callback: function(value) {
                            if (value >= 1000) return (value / 1000).toFixed(0) + 'k';
                            return value;
                        }
                    }
                }
            }
        }
    });
    
}
function RenderSingleChart(datasetName, labels, data, barColor) {
    const ctx = document.getElementById('myChart');

    if (chartInstance != null) {
        chartInstance.destroy();
    }

    chartInstance = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [
                {
                    label: datasetName,
                    data: data,
                    backgroundColor: barColor || '#3b82f6',
                    borderRadius: 3,
                    barPercentage: 0.6,
                    categoryPercentage: 0.7
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false }
            },
            scales: {
                x: {
                    grid: { display: false },
                    ticks: { font: { size: 10 } }
                },
                y: {
                    grid: { color: '#f0f0f0' },
                    ticks: {
                        font: { size: 10 },
                        callback: function(value) {
                            if (value >= 1000) return (value / 1000).toFixed(0) + 'k';
                            return value;
                        }
                    }
                }
            }
        }
    });
}
function RenderChart3(Dataset1Name, Dataset2Name, Dataset3Name, Labels, Data1, Data2, Data3) {
    var ctx = document.getElementById('myChart').getContext('2d');
    
    // Destroy previous chart instance if it exists to prevent overlap
    if (window.myChartInstance) {
        window.myChartInstance.destroy();
    }

    window.myChartInstance = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: Labels,
            datasets: [
                {
                    label: Dataset1Name,
                    data: Data1,
                    backgroundColor: '#14b8a6', // TEAL (Actuals)
                    borderWidth: 1
                },
                {
                    label: Dataset2Name,
                    data: Data2,
                    backgroundColor: '#f97316', // VIBRANT ORANGE (Budget/Schedule)
                    borderWidth: 1
                },
                {
                    label: Dataset3Name,
                    data: Data3,
                    backgroundColor: '#6366f1', // INDIGO (Variance/Profit)
                    borderWidth: 1
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: { beginAtZero: true }
            }
        }
    });
}