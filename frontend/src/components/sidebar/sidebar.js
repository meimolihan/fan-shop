export function initSidebar(currentPage) {
    const sidebarToggle = document.getElementById('sidebarToggle');
    const sidebar = document.querySelector('.sidebar');
    const logoutBtn = document.getElementById('logoutBtn');
    const navItems = document.querySelectorAll('.sidebar-nav li');
    
    sidebarToggle.addEventListener('click', function() {
        sidebar.classList.toggle('collapsed');
        const icon = sidebarToggle.querySelector('i');
        if (sidebar.classList.contains('collapsed')) {
            icon.classList.remove('fa-chevron-left');
            icon.classList.add('fa-chevron-right');
        } else {
            icon.classList.remove('fa-chevron-right');
            icon.classList.add('fa-chevron-left');
        }
    });
    
    // 移动端抽屉：汉堡按钮 + 遮罩
    const navToggle = document.createElement('button');
    navToggle.className = 'mobile-nav-toggle';
    navToggle.setAttribute('aria-label', '打开导航菜单');
    navToggle.innerHTML = '<i class="fas fa-bars"></i>';
    const mask = document.createElement('div');
    mask.className = 'sidebar-mask';
    document.body.appendChild(mask);
    document.body.appendChild(navToggle);

    function openNav() {
        sidebar.classList.add('open');
        document.body.classList.add('sidebar-open');
        navToggle.style.display = 'none';
        mask.classList.add('visible');
    }

    function closeNav() {
        sidebar.classList.remove('open');
        document.body.classList.remove('sidebar-open');
        navToggle.style.display = '';
        mask.classList.remove('visible');
    }

    navToggle.addEventListener('click', openNav);
    mask.addEventListener('click', closeNav);
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape' && sidebar.classList.contains('open')) closeNav();
    });
    sidebar.querySelectorAll('.sidebar-nav a').forEach(function(link) {
        link.addEventListener('click', closeNav);
    });
    window.addEventListener('resize', function() {
        if (window.innerWidth > 768 && sidebar.classList.contains('open')) closeNav();
    });
    
    logoutBtn.addEventListener('click', async function() {
        closeNav();
        if (confirm('确定要退出登录吗？')) {
            try {
                await fetch('/api/logout', { method: 'POST' });
            } catch (error) {
                // 即使请求失败也清除界面状态，避免用户误以为仍处于登录状态。
            }
            localStorage.removeItem('username');
            localStorage.removeItem('is_admin');
            localStorage.removeItem('remember');
            window.location.href = '../login/login.html';
        }
    });
    
    navItems.forEach(item => {
        const link = item.querySelector('a');
        if (link && link.href.includes(currentPage)) {
            item.classList.add('active');
        }
    });

    loadSidebarVersion();
}

async function loadSidebarVersion() {
    const versionElement = document.getElementById('sidebarVersion');
    if (!versionElement) return;

    try {
        const response = await fetch('/api/system/version');
        if (!response.ok) return;
        const result = await response.json();
        if (result.current_version) versionElement.textContent = result.current_version;
    } catch {
        // 保留 HTML 中的默认版本，侧边栏不能因版本请求失败而影响使用。
    }
}
